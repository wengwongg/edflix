require_relative '../spec_helper'

describe "Course CRUD" do
  describe "GET /courses/:id/edit" do
    context "when user is not logged in" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        visit "/courses/1/edit"
        expect(page).to have_current_path("/login") && have_selector('h4.error') &&
                          have_content("You must be logged in to access this site.")
      end
    end

    context "when course does not exist" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        login "test3@test.eu", "P4$$word"
        visit "/courses/100/edit"
        expect(page).to have_current_path("/courses") && have_selector('h4.error') &&
                          have_content("Course you're trying to access does not exist")
      end
    end

    context "when user has no permission to edit courses" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        login "test2@test.eu", "P4$$word"
        visit "/courses/1/edit"
        expect(page).to have_current_path("/courses") && have_selector('h4.error') &&
                          have_content("Access denied. You don't have enough permissions to access this site.")
      end
    end

    context "when user has permissions to edit courses" do
      it "loads page" do
        DbHelper.set_main_tables(true, true)
        login "test3@test.eu", "P4$$word"
        visit "/courses/1/edit"
        expect(page).to have_current_path("/courses/1/edit") && have_content("Edit course")
      end
    end
  end

  describe "POST /courses/:id/edit" do
    context "when user is not logged in" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        post "/courses/1/edit"
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/login")
        expect(session[:error]).to eq("You must be logged in to edit courses.")
      end
    end

    context "when course does not exist" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        post "/courses/100/edit", {}, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses")
        expect(session[:error]).to eq("Course you're trying to edit does not exist")
      end
    end

    context "when user has no permissions to edit this course" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        post "/courses/1/edit", {}, { "rack.session" => { id: 2 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses")
        expect(session[:error]).to eq("Access denied. You don't have enough permissions to edit courses.")
      end
    end

    context "when user is provider but didn't provide provider_id in param" do
      it "loads page with error" do
        DbHelper.set_main_tables(true, true)
        post "/courses/2/edit", {}, { "rack.session" => { id: 2 } }
        expect(last_response.body).to include("Selected provider is wrong")
      end
    end

    context "when user has all permissions and params are valid" do
      it "saves course successfully" do
        DbHelper.set_main_tables(true, true)
        post "/courses/2/edit", { "name" => "Test", "provider" => "1", "subject" => "1", "source_website" => "http://google.com",
                                  "description" => "testing description", "duration" => "5" }, { "rack.session" => { id: 2 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses/2/edit")
        expect(session[:info]).to eq("Course has been edited successfully.")
      end
    end
  end

  describe "POST /courses/:id/restore" do
    context "when user is not logged in" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        post "/courses/1/restore"
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses")
        expect(session[:error]).to eq("You must be logged in to restore courses.")
      end
    end

    context "when course does not exist" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        post "/courses/100/restore", {}, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses")
        expect(session[:error]).to eq("Course of id: 100 does not exist!")
      end
    end

    context "when course is not archived" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        post "/courses/1/restore", {}, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses")
        expect(session[:error]).to eq("Course of id: 1 has not been archived.")
      end
    end

    context "when user has no permissions to archive courses" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        Course.first(id: 1).delete
        post "/courses/1/restore", {}, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses")
        expect(session[:error]).to eq("You don't have enough permissions to restore courses!")
      end
    end

    context "when user has no permissions to archive this course" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        Course.first(id: 1).delete
        post "/courses/1/restore", {}, { "rack.session" => { id: 2 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses")
        expect(session[:error]).to eq("You don't have enough permissions to restore this course!")
      end
    end

    context "when user has enough permissions and course is archived" do
      it "restores the course" do
        DbHelper.set_main_tables(true, true)
        Course.first(id: 1).delete
        post "/courses/1/restore", {}, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses")
        expect(session[:info]).to eq("Course has been successfully restored.")
      end
    end
  end

  describe "GET /add-course" do
    context "when user is not logged in" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        visit "/add-course"
        expect(page).to have_current_path("/login") && have_selector('h4.error') &&
                          have_content("You must be logged in to access this site.")
      end
    end

    context "when user has no permission to add courses" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        login "test2@test.eu", "P4$$word"
        visit "/add-course"
        expect(page).to have_current_path("/courses") && have_selector('h4.error') &&
                          have_content("Access denied. You don't have enough permissions to access this site.")
      end
    end

    context "when trusted provider wasn't assigned provider organisation" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        user = User.first(id: 1)
        user.roles_ids = "1;2"
        user.save_changes
        login "test2@test.eu", "P4$$word"
        visit "/add-course"
        expect(page).to have_current_path("/courses") && have_selector('h4.error') &&
                          have_content("You cannot add courses until admin assigns you a provider name.")
      end
    end
  end

  describe "POST /add-course" do
    context "when user is not logged in" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        post "/add-course"
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/login")
        expect(session[:error]).to eq("You must be logged in to add courses.")
      end
    end

    context "when user has no permissions to add courses" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        post "/add-course", {}, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses")
        expect(session[:error]).to eq("Access denied. You don't have enough permissions to add courses.")
      end
    end

    context "when trusted provider wasn't assigned provider organisation" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        user = User.first(id: 1)
        user.roles_ids = "1;2"
        user.save_changes
        post "/add-course", {}, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses")
        expect(session[:error]).to eq("You cannot add courses until admin assigns you a provider name.")
      end
    end

    context "when user is provider but didn't provide provider_id in param" do
      it "loads page with error" do
        DbHelper.set_main_tables(true, true)
        post "/add-course", {}, { "rack.session" => { id: 2 } }
        expect(last_response.body).to include("Selected provider is wrong")
      end
    end

    context "when user has all permissions and params are valid" do
      it "saves course successfully" do
        DbHelper.set_main_tables(true, true)
        post "/add-course", { "name" => "Test", "provider" => "1", "subject" => "1", "source_website" => "http://google.com",
                                  "description" => "testing description", "duration" => "5" }, { "rack.session" => { id: 2 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses")
        expect(session[:info]).to eq("Course created successfully.")
      end
    end
  end
end
