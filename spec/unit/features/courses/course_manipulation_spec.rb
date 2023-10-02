require_relative "../../../spec_helper"

RSpec.describe "Course manipulation" do
  describe "leaving a filed empty" do
    it "will show the error message 'please correct the error below:'" do
      DbHelper.set_main_tables(false, true)
      login "test3@test.eu", "P4$$word"
      visit "/add-course"
      click_button "Save"
      expect(page).to have_content "Please correct the errors below:"
    end
  end
end
