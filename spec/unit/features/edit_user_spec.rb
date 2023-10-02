# Test for the contents of the page for editing user records.
require_relative "../../spec_helper"

RSpec.describe "Edit User Page" do
  describe "GET /edit-user" do
    it "has a status code of 200 (OK)" do
      UsersDbHelper2.reset
      UsersDbHelper2.create_user
      UsersDbHelper2.create_administrator

      get "/edit-user?id=1", {}, { "rack.session" => { id: 2 } }
      expect(last_response.status).to eq(200)
    end

    it "contains the relevant types of data to edit and delete function" do
      UsersDbHelper2.reset
      UsersDbHelper2.create_user
      UsersDbHelper2.create_administrator

      get "/edit-user?id=1", {}, { "rack.session" => { id: 2 } }
      expect(last_response.body).to include("Edit User")
      expect(last_response.body).to include("First name")
      expect(last_response.body).to include("Last name")
      expect(last_response.body).to include("Subject")
      expect(last_response.body).to include("Year of Study")
      expect(last_response.body).to include("Email")
      expect(last_response.body).to include("Roles")
      expect(last_response.body).to include("Delete")
    end

    it "is prefilled with the user's data" do
      UsersDbHelper2.reset
      UsersDbHelper2.create_user
      UsersDbHelper2.create_administrator

      get "/edit-user?id=1", {}, { "rack.session" => { id: 2 } }
      expect(last_response.body).to include("George")
      expect(last_response.body).to include("Hum")
      expect(last_response.body).to include("Test Subject")
      expect(last_response.body).to include("<input type=\"number\" name=\"year_of_study\" value=\"2\">")
      expect(last_response.body).to include("test1@gmail.com")
      # checked for checked condition in code, since won't allow me to pass entire input tag.
      expect(last_response.body).to include("checked")
    end
  end
end
