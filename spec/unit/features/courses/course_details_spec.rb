require_relative "../../../spec_helper"

describe "Courses details" do
  describe "GET /courses/1" do
    context "with an empty database" do
      it "says the database is empty" do
        CoursesDbHelper.reset
        CoursesDbHelper.create_subjects

        get "/courses/1"
        expect(last_response.status == 302 &&
                 last_response.headers['Location'] == "http://example.org/courses" &&
                 session[:error].eql?("No course for id: 1 was found."))
      end
    end

    context "with one record in the database" do
      it "gives a list with one course" do
        CoursesDbHelper.reset
        CoursesDbHelper.create_subjects
        # set up the testing database
        course = Course.new(name: "Test course", subject: 1, lecturer: "Prof Honey",
                            source_website: "https://google.com/", description: "Some description...", signups: 3,
                            start_date: 1_583_020_800, end_date: 1_583_020_800, duration: 1, is_public: 1)
        course.save_changes

        # perform the test
        get "/courses/1"
        expect(last_response.body).to include("Test course")
      end
    end
  end
end

describe "Liked Courses" do
  describe "POST /courses/1/like" do
    context "with the course not liked" do
      it "shows the Like Course button" do
        CoursesDbHelper.reset
        CoursesDbHelper.create_subjects

        course = Course.new(name: "Test course", subject: 1, lecturer: "Prof Honey",
                            source_website: "https://google.com/", description: "Some description...", signups: 3,
                            start_date: 1_583_020_800, end_date: 1_583_020_800, duration: 1, is_public: 1)
        course.save_changes

        get "/courses/1", {}, { "rack.session" => { id: 1 } }
        expect(last_response.body).to include("Like Course")
      end
    end
  end

  describe "POST /courses/1/dislike" do
    context "with the course liked" do
      it "shows the Dislike Course button" do
        CoursesDbHelper.reset
        CoursesDbHelper.create_subjects

        course = Course.new(name: "Test course", subject: 1, lecturer: "Prof Honey",
                            source_website: "https://google.com/", description: "Some description...", signups: 3,
                            start_date: 1_583_020_800, end_date: 1_583_020_800, duration: 1, is_public: 1)
        course.save_changes

        liked_course_entry = Liked_course.new(user_id: 1, course_id: 1)
        liked_course_entry.save_changes

        get "/courses/1", {}, { "rack.session" => { id: 1 } }
        expect(last_response.body).to include("Dislike Course")
      end
    end
  end
end
