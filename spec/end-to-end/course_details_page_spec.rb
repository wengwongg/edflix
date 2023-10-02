require_relative '../spec_helper'

describe "course details page" do
  context "for empty database" do
    it "says that no course of id: 100 was found" do
      CoursesDbHelper.reset
      CoursesDbHelper.create_subjects

      visit "/courses/100"
      expect(page).to have_current_path("/courses") && have_selector('h4.error') &&
                      have_content("No course for id 100 was found.")
    end
  end

  context "for not empty database" do
    it "gives information of course for id: 1" do
      DbHelper.set_main_tables(true, false)

      visit "/courses/1"
      expect(page).to have_content "NameFilter TestCourse"
      expect(page).to have_content "Computer Science"
      expect(page).to have_content "Prof Honey"
      expect(page).to have_content "Some description..."
    end

    it "gives information of course for id: 2" do
      DbHelper.set_main_tables(true, false)

      visit "/courses/2"
      expect(page).to have_content "SubjectFilter TestCourse"
      expect(page).to have_content "Something else"
      expect(page).to have_content "Prof Honey"
      expect(page).to have_content "Some description..."
    end

    it "gives error if course is archived and user is not logged in" do
      DbHelper.set_main_tables(true, false)
      Course.new(name: "Test TestCourse", subject: 1, lecturer: "Prof Jack Sparrow",
                 source_website: "https://google.com/", description: "Some description...", signups: 3,
                 start_date: 1_579_478_400, end_date: 1_583_020_800, duration: 1,
                 is_public: 1, tags: "2;4", is_archived: 1).save_changes
      visit "/courses/5"
      expect(page).to have_current_path("/") && have_selector('h4.error') &&
                        have_content("You must be logged in to see this site.")
    end

    it "gives error if course is archived and user does not have access to see it" do
      DbHelper.set_providers
      DbHelper.set_main_tables(true, false)
      Course.first(id: 1).delete
      login "test@test.eu", "P4$$word"
      visit "/courses/1"
      expect(page).to have_current_path("/") && have_selector('h4.error') &&
                        have_content("You don't have enough permissions to access this site.")
    end
  end
end
