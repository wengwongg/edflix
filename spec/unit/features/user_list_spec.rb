# tests for the contents of user-list page.
require_relative "../../spec_helper"

RSpec.describe "List of Users Page" do
  describe "GET /user-list" do
    it "has a status code of 200 (OK)" do
      UsersDbHelper2.reset
      UsersDbHelper2.create_user
      UsersDbHelper2.create_administrator
      get "/user-list", {}, { "rack.session" => { id: 2 } }
      expect(last_response.status).to eq(200)
    end

    it "includes fields to filter by email, subject and suspension status" do
      UsersDbHelper2.reset
      UsersDbHelper2.create_user
      UsersDbHelper2.create_administrator
      get "/user-list", {}, { "rack.session" => { id: 2 } }
      expect(last_response.body).to include("Type an email address...")
      expect(last_response.body).to include("Subject:")
      expect(last_response.body).to include("Suspension:")
    end

    it "includes headers for relevant user properties" do
      UsersDbHelper2.reset
      UsersDbHelper2.create_user
      UsersDbHelper2.create_administrator
      get "/user-list", {}, { "rack.session" => { id: 2 } }
      expect(last_response.body).to include("ID")
      expect(last_response.body).to include("Email")
      expect(last_response.body).to include("First Name")
      expect(last_response.body).to include("Last Name")
      expect(last_response.body).to include("Year of Study")
      expect(last_response.body).to include("Main Role")
      expect(last_response.body).to include("Staff")
      expect(last_response.body).to include("Subject")
      expect(last_response.body).to include("Suspension")
      expect(last_response.body).to include("Edit?")
    end

    it "includes data about users in the database" do
      UsersDbHelper2.reset
      UsersDbHelper2.create_user

      UsersDbHelper2.create_administrator
      get "/user-list", {}, { "rack.session" => { id: 2 } }
      expect(last_response.body).to include("1")
      expect(last_response.body).to include("test1@gmail.com")
      expect(last_response.body).to include("George")
      expect(last_response.body).to include("Hum")
      expect(last_response.body).to include("2")
      expect(last_response.body).to include("Student")
      expect(last_response.body).to include("false")
      expect(last_response.body).to include("Test Subject")
      # since new user is unsuspended, we'd have a suspend button.
      expect(last_response.body).to include("Suspend")
      expect(last_response.body).to include("Edit")
    end
  end
end
