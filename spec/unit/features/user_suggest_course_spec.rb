require_relative "../../spec_helper"

RSpec.describe "Suggest Course Page" do
  describe "GET /suggest-course" do
    it "has a status code of 200 (OK)" do
      UsersDbHelper2.reset
      UsersDbHelper2.create_user

      get "/suggest-course", {}, { "rack.session" => { id: 1 } }
      expect(last_response.status).to eq(200)
    end

    it "contains fields for course name and URL" do
      UsersDbHelper2.reset
      UsersDbHelper2.create_user

      get "/suggest-course", {}, { "rack.session" => { id: 1 } }
      expect(last_response.body).to include("Name of the course")
      expect(last_response.body).to include("URL of the course page")
    end
  end
end
