require_relative "../spec_helper"

RSpec.describe "course dashboard page" do
  describe "testing errors when user trying to see dashboard page should not be able to do it" do
    context "when user is not logged in" do
      it "redirects to home page and displays error" do
        visit "/mycourses"

        expect(page).to have_current_path("/") && have_selector('h4.error') &&
                        have_content("You must be logged in to see courses dashboard.")
      end
    end

    context "when user is not a student" do
      it "redirects to home page and displays error" do
        DbHelper.set_main_tables(false, true)
        login "test@test.eu", "P4$$word"
        visit "/mycourses"

        expect(page).to have_current_path("/") && have_selector('h4.error') &&
                        have_content("You must be a student in order to see courses dashboard.")
      end
    end
  end


  describe "user can enter courses dashboard page" do
    context "when student has never enrolled to any course" do
      it "shows empty list of courses" do
        DbHelper.set_main_tables(true, true)
        StudentCourseDbHelper.reset
        login "test2@test.eu", "P4$$word"
        visit "/mycourses"

        expect(page).to have_current_path("/mycourses") && have_content("Your courses history is empty.")
      end
    end

    context "when student has enrolled to two courses: 'NameFilter TestCourse' and 'SubjectFilter TestCourse'" do
      it "shows list containing two courses" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_student_courses
        login "test2@test.eu", "P4$$word"
        visit "/mycourses"

        expect(page).to have_current_path("/mycourses") && have_content("NameFilter TestCourse")
        expect(page).to have_content("SubjectFilter TestCourse")
      end
    end

    context "when student impose filters on courses list" do
      it "shows list containing 'NameFilter TestCourse' only when name filter is imposed" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_student_courses
        login "test2@test.eu", "P4$$word"
        visit "/mycourses"
        fill_in "course_name", with: "name"
        click_button "Filter"

        expect(page).to have_current_path("/mycourses") && have_content("NameFilter TestCourse")
        expect(page).not_to have_content("SubjectFilter TestCourse")
      end

      it "shows list containing 'SubjectFilter TestCourse' only when status=completed is chosen" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_student_courses
        login "test2@test.eu", "P4$$word"
        visit "/mycourses"
        select "Completed", from: "course_status"
        click_button "Filter"

        expect(page).to have_current_path("/mycourses") && have_content("SubjectFilter TestCourse")
        expect(page).not_to have_content("NameFilter TestCourse")
      end

      it "shows list containing 'NameFilter TestCourse' only when enroll_date=2023-04-29 exact is chosen" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_student_courses
        login "test2@test.eu", "P4$$word"
        visit "/mycourses"
        fill_in "enroll_date", with: "2023-04-29"
        check "enroll_date_exact"
        click_button "Filter"

        expect(page).to have_current_path("/mycourses") && have_content("NameFilter TestCourse")
        expect(page).not_to have_content("SubjectFilter TestCourse")
      end
    end
  end
end
