require_relative "../../spec_helper"

RSpec.describe "Account Details Page" do
  # tests for when landing initially on account-details page.
  # page for changing email and password.

  describe "GET /account-details" do
    it "has a status code of 200 (OK)" do
      UsersDbHelper2.reset
      UsersDbHelper2.create_user
      get "/account-details", {}, { "rack.session" => { id: 1 } }
      expect(last_response.status).to eq(200)
    end

    it "includes required fields to change email" do
      UsersDbHelper2.reset
      UsersDbHelper2.create_user
      get "/account-details", {}, { "rack.session" => { id: 1 } }
      expect(last_response.body).to include("New Email")
      expect(last_response.body).to include("Confirm Email")
    end

    it "includes required fields to change password" do
      UsersDbHelper2.reset
      UsersDbHelper2.create_user
      get "/account-details", {}, { "rack.session" => { id: 1 } }
      expect(last_response.body).to include("New Password")
      expect(last_response.body).to include("Confirm Password")
    end
  end
end
