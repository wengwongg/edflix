require_relative '../spec_helper'

describe "Staff contact page" do
  describe "GET /staff-contact" do
    it "loads page" do
      visit "/staff-contact"
      expect(page).to have_current_path("/staff-contact") && have_content("Contact Our Staff")
    end
  end

  describe "POST /staff-contact" do
    context "when one of the params is empty" do
      it "gives error" do
        visit "/staff-contact"
        fill_in 'name', with: "Test name"
        fill_in 'email', with: "Test email"
        click_on 'Send Message'
        expect(page).to have_current_path("/staff-contact") && have_content("Please enter a value for text")
      end
    end

    context "when all params are valid" do
      it "gives success message" do
        visit "/staff-contact"
        fill_in 'name', with: "Test name"
        fill_in 'email', with: "Test email"
        fill_in 'text', with: "Test text"
        click_on 'Send Message'
        expect(page).to have_current_path("/staff-contact") && have_content("Success!")
      end
    end
  end
end