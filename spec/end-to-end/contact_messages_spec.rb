require_relative '../spec_helper'

describe "User messages page" do
  describe "GET /messages" do
    context "when user is not logged in" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        visit "/messages"
        expect(page).to have_current_path("/") && have_selector('h4.error') &&
                        have_content("You must be logged in to access this site.")
      end
    end

    context "when user has no permission to access this page" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        login "test2@test.eu", "P4$$word"
        visit "/messages"
        expect(page).to have_current_path("/") && have_selector('h4.error') &&
                        have_content("You don't have enough permissions to access this site.")
      end
    end

    context "when user is logged in as admin" do
      it "loads the page" do
        UsersDbHelper2.reset
        UsersDbHelper2.create_administrator

        login "admin@gmail.com", "Test!!123"
        visit "/messages"
        expect(page).to have_current_path("/messages") && have_content("User Messages")
      end
    end
  end

  describe "DELETE /messages/:id" do
    context "when user is not logged in" do
      it "gives an error" do
        delete "/messages/1"
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/login")
        expect(session[:error]).to eq("You must be logged in to access this site.")
      end
    end

    context "when user has no permission to access this page" do
      it "gives an error" do
        DbHelper.set_main_tables(false, true)
        delete "/messages/1", {}, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/")
        expect(session[:error]).to eq("You don't have enough permissions to access this site.")
      end
    end

    context "when user is logged in as admin and message of given id does not exist" do
      it "gives an error" do
        UsersDbHelper2.reset
        UsersDbHelper2.create_administrator
        DB[:sqlite_sequence].where(name: "staff_contact").delete
        DB[:staff_contact].delete

        delete "/messages/1", {}, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/messages")
        expect(session[:error]).to eq("Message you're trying to delete does not exist.")
      end
    end

    context "when user is logged in as admin and message of given id does exist" do
      it "deletes a message" do
        UsersDbHelper2.reset
        UsersDbHelper2.create_administrator
        DB[:sqlite_sequence].where(name: "staff_contact").delete
        DB[:staff_contact].delete
        StaffContact.new(name: "test", email: "test", text: "text", date: DateParse.today_utc_unix).save_changes

        delete "/messages/1", {}, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/messages")
        expect(session[:info]).to eq("Message was deleted successfully.")
      end

    end
  end
end