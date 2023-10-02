require_relative '../spec_helper'

describe "My courses page" do
  describe "GET /mycourses" do
    context "when user is not logged in" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        visit "/mycourses"
        expect(page).to have_current_path("/") && have_selector('h4.error') &&
                          have_content("You must be logged in to see courses dashboard.")
      end
    end

    context "when user is not a student" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        login "test3@test.eu", "P4$$word"
        visit "/mycourses"
        expect(page).to have_current_path("/") && have_selector('h4.error') &&
                          have_content("You must be a student in order to see courses dashboard.")
      end
    end

    context "when user is a student" do
      it "loads the page" do
        DbHelper.set_main_tables(true, true)
        login "test2@test.eu", "P4$$word"
        visit "/mycourses"
        expect(page).to have_current_path("/mycourses") && have_content("Courses Dashboard")
      end
    end
  end

  describe "GET /courses/:id/enroll" do
    context "when user is not logged in" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        get "/courses/1/enroll"
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses/1")
        expect(session[:error]).to eq("You must be logged in to enroll to a course.")
      end
    end

    context "when course is private" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        course = Course.first(id: 1)
        course.is_public = 0
        course.save_changes
        get "/courses/1/enroll", {}, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses/1")
        expect(session[:error]).to eq("You cannot enroll to this course. This course is private.")
      end
    end

    context "when course is archived" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        course = Course.first(id: 1)
        course.is_archived = 1
        course.save_changes
        get "/courses/1/enroll", {}, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses/1")
        expect(session[:error]).to eq("You cannot enroll to this course. This course is archived.")
      end
    end

    context "when user is not a student" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        get "/courses/1/enroll", {}, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses/1")
        expect(session[:error]).to eq("You must be a student in order to enroll to a course.")
      end
    end

    context "when user is already enrolled in this course" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_student_courses
        get "/courses/1/enroll", {}, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses/1")
        expect(session[:error]).to eq("You are already enrolled to this course.")
      end
    end

    context "when student is not enrolled in this course" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        StudentCourseDbHelper.reset
        get "/courses/1/enroll", {}, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses/1")
        expect(session[:info]).to eq("You are now enrolled to course NameFilter TestCourse.")
      end
    end
  end

  describe "GET /courses/:id/pause" do
    context "when user is not logged in" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        get "/courses/1/pause"
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses/1")
        expect(session[:error]).to eq("You must be logged in to pause a course.")
      end
    end

    context "when user is not a student" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_student_courses
        get "/courses/1/pause", {}, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses/1")
        expect(session[:error]).to eq("You must be a student in order to pause a course.")
      end
    end

    context "when student is not enrolled in this course" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        StudentCourseDbHelper.reset
        get "/courses/1/pause", {}, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses/1")
        expect(session[:error]).to eq("You cannot pause a course you are not enrolled to.")
      end
    end

    context "when student has already paused this course" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_student_courses
        course = StudentCourse.first(course_id: 1)
        course.status = 2
        course.save_changes
        get "/courses/1/pause", {}, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses/1")
        expect(session[:error]).to eq("You have already paused this course.")
      end
    end

    context "when student has already completed this course" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_student_courses
        course = StudentCourse.first(course_id: 1)
        course.status = 3
        course.save_changes
        get "/courses/1/pause", {}, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses/1")
        expect(session[:error]).to eq("You cannot pause finished course.")
      end
    end

    context "when student has enrolled in this course" do
      it "pauses course successfully" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_student_courses
        get "/courses/1/pause", {}, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses/1")
        expect(session[:info]).to eq("You have successfully paused course NameFilter TestCourse.")
      end
    end
  end

  describe "GET /courses/:id/resume" do
    context "when user is not logged in" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        get "/courses/1/resume"
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses/1")
        expect(session[:error]).to eq("You must be logged in to resume a course.")
      end
    end

    context "when user is not a student" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_student_courses
        get "/courses/1/resume", {}, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses/1")
        expect(session[:error]).to eq("You must be a student in order to resume a course.")
      end
    end

    context "when student is not enrolled in this course" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        StudentCourseDbHelper.reset
        get "/courses/1/resume", {}, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses/1")
        expect(session[:error]).to eq("You cannot resume a course you are not enrolled to.")
      end
    end

    context "when student hasn't paused this course" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_student_courses
        get "/courses/1/resume", {}, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses/1")
        expect(session[:error]).to eq("You cannot resume course which is not paused.")
      end
    end

    context "when student has already completed this course" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_student_courses
        course = StudentCourse.first(course_id: 1)
        course.status = 3
        course.save_changes
        get "/courses/1/resume", {}, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses/1")
        expect(session[:error]).to eq("You cannot resume completed course.")
      end
    end

    context "when student has paused this course" do
      it "resumes course successfully" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_student_courses
        course = StudentCourse.first(course_id: 1)
        course.status = 2
        course.save_changes
        get "/courses/1/resume", {}, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses/1")
        expect(session[:info]).to eq("You have successfully resumed course NameFilter TestCourse.")
      end
    end
  end

  describe "GET /courses/:id/cancel" do
    context "when user is not logged in" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        get "/courses/1/cancel"
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses/1")
        expect(session[:error]).to eq("You must be logged in to cancel a course.")
      end
    end

    context "when user is not a student" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_student_courses
        get "/courses/1/cancel", {}, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses/1")
        expect(session[:error]).to eq("You must be a student in order to cancel a course.")
      end
    end

    context "when student is not enrolled in this course" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        StudentCourseDbHelper.reset
        get "/courses/1/cancel", {}, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses/1")
        expect(session[:error]).to eq("You cannot cancel a course you are not enrolled to.")
      end
    end

    context "when student has completed this course" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_student_courses
        course = StudentCourse.first(course_id: 1)
        course.status = 3
        course.save_changes
        get "/courses/1/cancel", {}, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses/1")
        expect(session[:error]).to eq("You cannot cancel completed course.")
      end
    end

    context "when student is enrolled in this course (or paused)" do
      it "cancels course successfully" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_student_courses
        get "/courses/1/cancel", {}, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses/1")
        expect(session[:info]).to eq("You have successfully cancelled course NameFilter TestCourse.")
      end
    end
  end

  describe "GET /courses/:id/finish" do
    context "when user is not logged in" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        get "/courses/1/finish"
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses/1")
        expect(session[:error]).to eq("You must be logged in to finish a course.")
      end
    end

    context "when user is not a student" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_student_courses
        get "/courses/1/finish", {}, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses/1")
        expect(session[:error]).to eq("You must be a student in order to finish a course.")
      end
    end

    context "when student is not enrolled in this course" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        StudentCourseDbHelper.reset
        get "/courses/1/finish", {}, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses/1")
        expect(session[:error]).to eq("You cannot finish a course you are not enrolled to.")
      end
    end

    context "when student has already completed this course" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_student_courses
        course = StudentCourse.first(course_id: 1)
        course.status = 3
        course.save_changes
        get "/courses/1/finish", {}, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses/1")
        expect(session[:error]).to eq("You have already completed this course.")
      end
    end

    context "when student is enrolled in this course (or paused)" do
      it "completes course successfully" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_student_courses
        get "/courses/1/finish", {}, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses/1")
        expect(session[:info]).to eq("You have successfully completed course NameFilter TestCourse.")
      end
    end
  end
end