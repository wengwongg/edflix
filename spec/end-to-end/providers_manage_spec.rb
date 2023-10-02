require_relative '../spec_helper'

describe "Providers manage page" do
  describe "GET /providers-manage" do
    context "when user is not logged in" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        visit "/providers-manage"
        expect(page).to have_current_path("/") && have_selector('h4.error') &&
                          have_content("You must be logged in to access this site.")
      end
    end

    context "when user has no permission to access this page" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        login "test2@test.eu", "P4$$word"
        visit "/providers-manage"
        expect(page).to have_current_path("/") && have_selector('h4.error') &&
                          have_content("Access denied. You don't have enough permissions to access this site.")
      end
    end

    context "when user has permissions to access this page" do
      it "loads page successfully" do
        UsersDbHelper2.reset
        UsersDbHelper2.create_administrator

        login "admin@gmail.com", "Test!!123"
        visit "/providers-manage"
        expect(page).to have_current_path("/providers-manage") && have_content("Manage trusted providers")
      end
    end
  end

  describe "POST /providers-manage/provider" do
    context "when user is not logged in" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        post "/providers-manage/provider"
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/login")
        expect(session[:error]).to eq("You must be logged in to access this site.")
      end
    end

    context "when user has no permissions to access site" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        post "/providers-manage/provider", {}, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/")
        expect(session[:error]).to eq("Access denied. You don't have enough permissions to access this site.")
      end
    end

    context "when user has no permissions to create providers" do
      it "gives an error" do
        UsersDbHelper2.reset
        UsersDbHelper2.create_administrator
        policy = Policy.first(name: "manage_providers")
        policy.permissions = "providers.manage.access"
        policy.save_changes
        post "/providers-manage/provider", {}, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/providers-manage")
        expect(session[:error]).to eq("You don't have enough permissions to create providers.")
      end
    end

    context "when provider with that name already exist" do
      it "gives an error" do
        UsersDbHelper2.reset
        UsersDbHelper2.create_administrator
        DbHelper.set_main_tables(true, false)
        DbHelper.set_providers
        policy = Policy.first(name: "manage_providers")
        policy.permissions = "providers.manage.access;providers.create"
        policy.save_changes
        post "/providers-manage/provider", { "name" => "Test provider" }, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/providers-manage")
        expect(session[:error]).to eq("Provider with provided name already exist.")
      end
    end

    context "when provider name contains special characters" do
      it "gives an error" do
        UsersDbHelper2.reset
        UsersDbHelper2.create_administrator
        policy = Policy.first(name: "manage_providers")
        policy.permissions = "providers.manage.access;providers.create"
        policy.save_changes
        post "/providers-manage/provider", { "name" => "Test providerr%" }, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/providers-manage")
        expect(session[:error]).to eq("You cannot put any special characters in provider name.")
      end
    end

    context "when provider name is empty" do
      it "gives an error" do
        UsersDbHelper2.reset
        UsersDbHelper2.create_administrator
        policy = Policy.first(name: "manage_providers")
        policy.permissions = "providers.manage.access;providers.create"
        policy.save_changes
        post "/providers-manage/provider", {}, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/providers-manage")
        expect(session[:error]).to eq("Something went wrong. Cannot create a provider.")
      end
    end

    context "when all params are valid and user has permissions" do
      it "creates provider successfully" do
        UsersDbHelper2.reset
        UsersDbHelper2.create_administrator
        UsersDbHelper.reset_providers
        policy = Policy.first(name: "manage_providers")
        policy.permissions = "providers.manage.access;providers.create"
        policy.save_changes
        post "/providers-manage/provider", { "name" => "Jetbrains" }, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/providers-manage")
        expect(session[:info]).to eq("Provider with name: Jetbrains has been successfully created.")
      end
    end
  end

  describe "DELETE /providers-manage/provider" do
    context "when user is not logged in" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        delete "/providers-manage/provider"
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/login")
        expect(session[:error]).to eq("You must be logged in to access this site.")
      end
    end

    context "when user has no permissions to access site" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        delete "/providers-manage/provider", {}, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/")
        expect(session[:error]).to eq("Access denied. You don't have enough permissions to access this site.")
      end
    end

    context "when user has no permissions to delete providers" do
      it "gives an error" do
        UsersDbHelper2.reset
        UsersDbHelper2.create_administrator
        policy = Policy.first(name: "manage_providers")
        policy.permissions = "providers.manage.access"
        policy.save_changes
        delete "/providers-manage/provider", {}, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/providers-manage")
        expect(session[:error]).to eq("You don't have enough permissions to delete a provider.")
      end
    end

    context "when provider with that id does not exist" do
      it "gives an error" do
        UsersDbHelper2.reset
        UsersDbHelper2.create_administrator
        policy = Policy.first(name: "manage_providers")
        policy.permissions = "providers.manage.access;providers.delete"
        policy.save_changes
        delete "/providers-manage/provider", { "provider" => "20" }, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/providers-manage")
        expect(session[:error]).to eq("It seems that selected provider does not exist.")
      end
    end

    context "when all params are valid and user has permissions" do
      it "deletes provider successfully" do
        UsersDbHelper2.reset
        UsersDbHelper2.create_administrator
        DbHelper.set_main_tables(true, false)
        DbHelper.set_providers
        policy = Policy.first(name: "manage_providers")
        policy.permissions = "providers.manage.access;providers.delete"
        policy.save_changes
        delete "/providers-manage/provider", { "provider" => "1" }, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/providers-manage")
        expect(session[:info]).to eq("Provider has been successfully deleted.")
      end
    end
  end

  describe "PUT /providers-manage/provider" do
    context "when user is not logged in" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        put "/providers-manage/provider"
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/login")
        expect(session[:error]).to eq("You must be logged in to access this site.")
      end
    end

    context "when user has no permissions to access site" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        put "/providers-manage/provider", {}, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/")
        expect(session[:error]).to eq("Access denied. You don't have enough permissions to access this site.")
      end
    end

    context "when user has no permissions to create providers" do
      it "gives an error" do
        UsersDbHelper2.reset
        UsersDbHelper2.create_administrator
        policy = Policy.first(name: "manage_providers")
        policy.permissions = "providers.manage.access"
        policy.save_changes
        put "/providers-manage/provider", {}, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/providers-manage")
        expect(session[:error]).to eq("You don't have enough permissions to edit a provider.")
      end
    end

    context "when selected provider does not exist" do
      it "gives an error" do
        UsersDbHelper2.reset
        UsersDbHelper2.create_administrator
        DbHelper.set_main_tables(true, false)
        DbHelper.set_providers
        policy = Policy.first(name: "manage_providers")
        policy.permissions = "providers.manage.access;providers.edit"
        policy.save_changes
        put "/providers-manage/provider", { "provider" => "100" }, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/providers-manage")
        expect(session[:error]).to eq("You must select a provider you want to edit.")
      end
    end

    context "when provider with that name already exist" do
      it "gives an error" do
        UsersDbHelper2.reset
        UsersDbHelper2.create_administrator
        DbHelper.set_main_tables(true, false)
        DbHelper.set_providers
        policy = Policy.first(name: "manage_providers")
        policy.permissions = "providers.manage.access;providers.edit"
        policy.save_changes
        put "/providers-manage/provider", { "provider" => "2", "name" => "Test provider" }, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/providers-manage")
        expect(session[:error]).to eq("Provider with provided name already exist.")
      end
    end

    context "when provider name contains special characters" do
      it "gives an error" do
        UsersDbHelper2.reset
        UsersDbHelper2.create_administrator
        policy = Policy.first(name: "manage_providers")
        policy.permissions = "providers.manage.access;providers.edit"
        policy.save_changes
        put "/providers-manage/provider", { "provider" => "2", "name" => "Test providerr%" }, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/providers-manage")
        expect(session[:error]).to eq("You cannot put any special characters in provider name.")
      end
    end

    context "when provider name is empty" do
      it "gives an error" do
        UsersDbHelper2.reset
        UsersDbHelper2.create_administrator
        DbHelper.set_main_tables(true, false)
        DbHelper.set_providers
        policy = Policy.first(name: "manage_providers")
        policy.permissions = "providers.manage.access;providers.edit"
        policy.save_changes
        put "/providers-manage/provider", { "provider" => "2", "name" => "" }, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/providers-manage")
        expect(session[:error]).to eq("Something went wrong. Cannot edit selected provider.")
      end
    end

    context "when all params are valid and user has permissions" do
      it "creates provider successfully" do
        UsersDbHelper2.reset
        UsersDbHelper2.create_administrator
        DbHelper.set_main_tables(true, false)
        DbHelper.set_providers
        policy = Policy.first(name: "manage_providers")
        policy.permissions = "providers.manage.access;providers.edit"
        policy.save_changes
        put "/providers-manage/provider", { "provider" => "1", "name" => "Jetbrains" }, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/providers-manage")
        expect(session[:info]).to eq("Provider has been successfully edited.")
      end
    end
  end
end