require "sequel"
require_relative "../../spec_helper"

RSpec.describe User do
  # New passwords and emails to change to
  new_email = "#{SecureRandom.hex}@abc.com"
  new_password = "#{SecureRandom.hex}1*$"

  describe "#change_email" do
    it "changes the user's email" do
      UsersDbHelper2.reset
      UsersDbHelper2.create_user

      user = described_class.first(id: 1)
      user.change_email(new_email)
      expect(user.email).to eq(new_email)
    end
  end

  describe "#change_password" do
    it "changes the user's password" do
      UsersDbHelper2.reset
      UsersDbHelper2.create_user

      user = described_class.first(id: 1)
      current_hashed_password = user.password
      user.change_password(new_password)
      new_hashed_password = user.password
      expect(current_hashed_password == new_hashed_password).to be false
    end
  end

  describe "#existing_email" do
    it "checks if there is an existing email in the database" do
      UsersDbHelper2.reset
      UsersDbHelper2.create_many_users

      user = described_class.first(id: 1)
      user2 = described_class.first(id: 2)
      existing_email_result = user.existing_email(user2.email)
      expect(existing_email_result).to be true
    end
  end

  describe "#get_user_info" do
    it "gets a user's corresponding user_infos record" do
      UsersDbHelper2.reset
      # this creates their corresponding user_info record as well.
      UsersDbHelper2.create_user

      user = described_class.first(id: 1)
      result = user.get_user_info(user.id)
      expect(result).to eq(["George", "Hum", 1, 2])
    end
  end

  describe "#assign_providers" do
    it "adds provider to user provider_ids column" do
      DbHelper.set_main_tables(true, true)
      DbHelper.set_providers
      user = described_class.first(id: 1)
      user.assign_providers([1])
      expect(user.provider_ids).to eq("1")
    end
  end

  describe "#moderator?" do
    it "returns false if user is not a moderator" do
      DbHelper.set_main_tables(false, true)
      expect(described_class.first(id: 1).moderator?).to be(false)
    end

    it "returns true if user is a moderator" do
      DbHelper.set_main_tables(false, true)
      expect(described_class.first(id: 3).moderator?).to be(true)
    end
  end
end
