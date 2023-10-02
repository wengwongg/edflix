require_relative "../spec_helper"

RSpec.describe "Viewing Report Page" do
  describe "report_page permission" do
    context "when user is not logged in" do
      it "does not display manager button" do
        DbHelper.set_main_tables(true, true)
        visit "/courses"
        expect(page).not_to have_css("manager-menu")
      end
    end

    context "when user logged in has no manager role" do
      it "does not display add/edit review form" do
        DbHelper.set_main_tables(true, true)
        login "test@test.eu", "P4$$word"
        visit "/courses"
        expect(page).not_to have_css("div#manager-menu")
      end
    end

    context "when user logged in has manager role" do
      it "ables to view report page" do
        DbHelper.set_main_tables(true, true)
        login "testmanager@test.eu", "P4$$word"
        get "/report", {}, { "rack.session" => { id: 4 } }
        expect(last_response.body).to include("Report Page")
      end

      it "displays manager buttons" do
        DbHelper.set_main_tables(true, true)
        # ReviewsDbHelper.reset
        login "testmanager@test.eu", "P4$$word"
        visit "/courses"
        expect(page).not_to have_css("student-menu")
      end

      it "displays list of providers properly" do
        DbHelper.set_main_tables(true, true)
        login "testmanager@test.eu", "P4$$word"
        visit "/report"


        # set up the test
        DbHelper.set_providers

        # perform the test by going to the page and examining the content
        get "/report", {}, { "rack.session" => { id: 4 } }
        expect(last_response.body).to include("Test provider")
      end

      it "displays no providers" do
        DbHelper.set_main_tables(true, true)
        login "testmanager@test.eu", "P4$$word"
        visit "/report"

        DbHelper.set_providers
        UsersDbHelper.reset_providers

        # perform the test by going to the page and examining the content
        get "/report", {}, { "rack.session" => { id: 4 } }
        expect(last_response.body).to include("There is no registered providers at the moment")
      end
    end
  end
end
