require_relative "../../../spec_helper"

RSpec.describe "Course list and delete" do
  describe "GET /courses" do
    context "with an empty database" do
      it "says the database is empty" do
        CoursesDbHelper.reset
        CoursesDbHelper.create_subjects

        get "/courses"
        expect(last_response.body).to include("No courses were found")
      end
    end

    context "with one record in the database" do
      it "gives a list with one course" do
        CoursesDbHelper.reset
        CoursesDbHelper.create_subjects

        # set up the testing database
        course = Course.new(name: "TestCourseRecord", subject: 1, lecturer: "Prof Honey",
                            source_website: "https://google.com/", description: "Some description...", signups: 3,
                            start_date: 1_583_020_800, end_date: 1_583_020_800, duration: 1, is_public: 1)
        course.save_changes

        # perform the test
        get "/courses"
        expect(last_response.body).to include("TestCourseRecord")
      end
    end

    context "with 5 records in the database where 1 is not published" do
      it "gives a list with 4 records if user is not logged in" do
        DbHelper.set_main_tables(true, true)
        Course.new(name: "TestCourseRecord", subject: 1, lecturer: "Prof Honey",
                   source_website: "https://google.com/", description: "Some description...", signups: 3,
                   start_date: 1_583_020_800, end_date: 1_583_020_800, duration: 1, is_public: 0).save_changes

        get "/courses"
        expect(last_response.body).not_to include("<td>TestCourseRecord</td>")
        expect(last_response.body).to include(
          "<td>LecturerFilter TestCourse</td>",
          "<td>NameFilter TestCourse</td>",
          "<td>TestFilter TestCourse</td>",
          "<td>SubjectFilter TestCourse</td>"
        )
      end

      it "gives a list with 4 records if logged user has no permission to view not published courses" do
        DbHelper.set_main_tables(true, true)
        Course.new(name: "TestCourseRecord", subject: 1, lecturer: "Prof Honey",
                   source_website: "https://google.com/", description: "Some description...", signups: 3,
                   start_date: 1_583_020_800, end_date: 1_583_020_800, duration: 1, is_public: 0).save_changes

        get "/courses", {}, { "rack.session" => { id: 1 } }
        expect(last_response.body).not_to include("<td>TestCourseRecord</td>")
        expect(last_response.body).to include(
          "<td>LecturerFilter TestCourse</td>",
          "<td>NameFilter TestCourse</td>",
          "<td>TestFilter TestCourse</td>",
          "<td>SubjectFilter TestCourse</td>"
        )
      end

      it "gives a list with 5 records if logged_user is provider for this course" do
        DbHelper.set_main_tables(true, true)
        Course.new(name: "TestCourseRecord", subject: 1, lecturer: "Prof Honey",
                   source_website: "https://google.com/", description: "Some description...", signups: 3,
                   start_date: 1_583_020_800, end_date: 1_583_020_800, duration: 1, provider: "1", is_public: 0).save_changes

        get "/courses", {}, { "rack.session" => { id: 2 } }
        expect(last_response.body).to include(
          "<td>TestCourseRecord</td>",
          "<td>LecturerFilter TestCourse</td>",
          "<td>NameFilter TestCourse</td>",
          "<td>TestFilter TestCourse</td>",
          "<td>SubjectFilter TestCourse</td>"
        )
      end

      it "gives a list with 4 records if logged user has permission to view not published courses" do
        DbHelper.set_main_tables(true, true)
        Course.new(name: "TestCourseRecord", subject: 1, lecturer: "Prof Honey",
                   source_website: "https://google.com/", description: "Some description...", signups: 3,
                   start_date: 1_583_020_800, end_date: 1_583_020_800, duration: 1, is_public: 0).save_changes

        get "/courses", {}, { "rack.session" => { id: 3 } }
        expect(last_response.body).to include(
          "<td>TestCourseRecord</td>",
          "<td>LecturerFilter TestCourse</td>",
          "<td>NameFilter TestCourse</td>",
          "<td>TestFilter TestCourse</td>",
          "<td>SubjectFilter TestCourse</td>"
        )
      end
    end
  end

  describe "DELETE /courses/:id" do
    describe "with non existing course id" do
      context "client not logged in" do
        it "says that you need to log in to delete courses" do
          delete "/courses/100000"
          expect(last_response.status).to eq(302)
          expect(last_response.headers['Location']).to eq('http://example.org/courses')
          expect(session[:error]).to eq("You must be logged in to archive courses.")
        end
      end

      context "client logged in" do
        it "says that course for given id (100000) does not exist" do
          DbHelper.set_main_tables(false, false)

          delete "/courses/100000", {}, { "rack.session" => { id: 1 } }
          expect(last_response.status).to eq(302)
          expect(last_response.headers['Location']).to eq('http://example.org/courses')
          expect(session[:error]).to eq("Course of id: 100000 does not exist!")
        end
      end
    end

    describe "with existing course id" do
      context "with user logged in with student role only" do
        it "says that logged user has no permissions to delete courses" do
          DbHelper.set_main_tables(true, true)
          new_course = Course.first(name: "NameFilter TestCourse")

          delete "/courses/#{new_course.id}", {}, { "rack.session" => { id: 1 } }
          expect(last_response.status).to eq(302)
          expect(last_response.headers['Location']).to eq("http://example.org/courses")
          expect(session[:error]).to eq("You don't have enough permissions to archive courses!")
        end
      end

      context "with user logged in with provider role, but trying to delete course which does not belong to the provider" do
        it "says that user has no permissions to delete this course" do
          DbHelper.set_main_tables(true, true)
          new_course = Course.first(name: "NameFilter TestCourse")

          delete "/courses/#{new_course.id}", {}, { "rack.session" => { id: 2 } }
          expect(last_response.status).to eq(302)
          expect(last_response.headers['Location']).to eq("http://example.org/courses")
          expect(session[:error]).to eq("You don't have enough permissions to archive this course!")
        end
      end

      context "with user logged in with provider role and trying to delete course which belongs to the provider" do
        it "deletes the course successfully" do
          DbHelper.set_main_tables(true, true)
          new_course = Course.first(name: "SubjectFilter TestCourse")

          delete "/courses/#{new_course.id}", {}, { "rack.session" => { id: 2 } }
          expect(last_response.status).to eq(302)
          expect(session[:error]).to be_nil
          expect(last_response.headers['Location']).to eq("http://example.org/courses")
        end
      end

      context "with user logged in with moderator role" do
        it "deletes the course successfully" do
          DbHelper.set_main_tables(true, true)
          new_course = Course.first(name: "SubjectFilter TestCourse")

          delete "/courses/#{new_course.id}", {}, { "rack.session" => { id: 3 } }
          expect(last_response.status).to eq(302)
          expect(session[:error]).to be_nil
          expect(last_response.headers['Location']).to eq("http://example.org/courses")
        end
      end

      context "when course is already deleted/archived" do
        it "gives an error" do
          DbHelper.set_main_tables(true, true)
          Course.first(id: 1).delete
          delete "/courses/1", {}, { "rack.session" => { id: 3 } }
          expect(last_response.status).to eq(302)
          expect(session[:error]).to eq("Course of id: 1 is already archived.")
          expect(last_response.headers['Location']).to eq("http://example.org/courses")
        end
      end
    end
  end
end
