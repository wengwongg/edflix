require_relative "../../../spec_helper"

describe "Liked courses" do
  describe "get /liked-courses" do
    context "with no liked courses" do
      it "says You have no liked courses" do
        DbHelper.set_main_tables(true, false)

        get "/liked-courses", {}, { "rack.session" => { id: 1 } }
        expect(last_response.body).to include("You have no liked courses")
      end
    end

    context "with a liked course" do
      it "shows a table with the course id and course name" do
        DbHelper.set_main_tables(true, false)
        liked_course = Liked_course.new(user_id: 1, course_id: 1)
        liked_course.save_changes

        get "/liked-courses", {}, { "rack.session" => { id: 1 } }
        expect(last_response.body).to include("1")
      end
    end
  end
end
