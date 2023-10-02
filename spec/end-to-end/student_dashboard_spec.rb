require_relative '../spec_helper'

describe "Student dashboard" do
  context "user is not logged in" do
    it "gives an error" do
      DbHelper.set_main_tables(true, true)
      visit "/student-dashboard"
      expect(page).to have_current_path("/") && have_selector('h4.error') &&
                        have_content("You must be logged in to see student dashboard.")
    end
  end

  context "when user is not a student" do
    it "gives an error" do
      DbHelper.set_main_tables(true, true)
      login "test3@test.eu", "P4$$word"
      visit "/student-dashboard"
      expect(page).to have_current_path("/") && have_selector('h4.error') &&
                        have_content("You must be a student in order to see student dashboard.")
    end
  end

  context "when user is a student" do
    it "loads the page" do
      DbHelper.set_main_tables(true, true)
      login "test2@test.eu", "P4$$word"
      visit "/student-dashboard"
      expect(page).to have_current_path("/student-dashboard") && have_content("Student Dashboard")
    end
  end
end
