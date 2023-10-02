require_relative '../spec_helper'

describe "Other pages" do
  describe "Accessibility" do
    it "loads page" do
      visit "/accessibility"
      expect(page).to have_current_path("/accessibility") && have_content("Accessibility")
    end
  end

  describe "Cookies" do
    it "loads page" do
      visit "/cookies"
      expect(page).to have_current_path("/cookies") && have_content("Cookies")
    end
  end

  describe "logout" do
    it "clears session" do
      get "/logout"
      expect(session[:id]).to be_nil
    end

    it "displays page" do
      visit "/logout"
      expect(page).to have_current_path("/logout") && have_content("You have been logged out successfully.")
    end
  end

  describe "reset-password" do
    context "if user didn't click on the link" do
      it "gives an error" do
        visit "/reset-password"
        expect(page).to have_current_path("/reset-password") && have_content("This hash is empty and not valid")
      end
    end
  end
end