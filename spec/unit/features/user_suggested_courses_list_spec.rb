require_relative "../../spec_helper"

RSpec.describe "List of User Suggested Courses Page" do
  describe "GET /user-suggested-courses" do
    it "has status code of 200" do
      UsersDbHelper2.reset
      UsersDbHelper2.create_moderator

      get "/user-suggested-courses", {}, { "rack.session" => { id: 1 } }
      expect(last_response.status).to eq(200)
    end

    it "contains data about user id, course name, course url and delete option" do
      UsersDbHelper2.reset
      UsersDbHelper2.create_moderator

      # create a new suggested course
      new_suggested_course = User_suggested_course.new(user_id: 1, name: "Test Course", url: "https://google.com")
      new_suggested_course.save_changes

      get "/user-suggested-courses", {}, { "rack.session" => { id: 1 } }
      expect(last_response.body).to include("User ID")
      expect(last_response.body).to include("Course Name")
      expect(last_response.body).to include("Course URL")
      expect(last_response.body).to include("Delete?")

      expect(last_response.body).to include("1")
      expect(last_response.body).to include("Test Course")
      expect(last_response.body).to include("https://google.com")
      expect(last_response.body).to include("Delete")
    end
  end
end
