require_relative '../spec_helper'

describe "User messages page" do
  describe "GET /courses-manage" do
    context "when user is not logged in" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        visit "/courses-manage"
        expect(page).to have_current_path("/") && have_selector('h4.error') &&
                          have_content("You must be logged in to access this site.")
      end
    end

    context "when user has no permission to access this page" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        login "test2@test.eu", "P4$$word"
        visit "/courses-manage"
        expect(page).to have_current_path("/") && have_selector('h4.error') &&
                          have_content("Access denied. You don't have enough permissions to access this site.")
      end
    end

    context "when user is logged in as a moderator/provider" do
      it "loads the page" do
        DbHelper.set_main_tables(true, true)
        login "test3@test.eu", "P4$$word"
        visit "/courses-manage"
        expect(page).to have_current_path("/courses-manage") && have_content("Manage course properties")
      end
    end
  end

  describe "POST /courses-manage/subject" do
    context "when user is not logged in" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        post "/courses-manage/subject"
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/login")
        expect(session[:error]).to eq("You must be logged in to access this site.")
      end
    end

    context "when user has no permissions to access site" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        post "/courses-manage/subject", {}, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/")
        expect(session[:error]).to eq("Access denied. You don't have enough permissions to access this site.")
      end
    end

    context "when user has no permissions to create providers" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "provide_subjects")
        policy.permissions = "subjects.manage.access"
        policy.save_changes
        post "/courses-manage/subject", {}, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:error]).to eq("You don't have enough permissions to create a subject.")
      end
    end

    context "when provider with that name already exist" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "provide_subjects")
        policy.permissions = "subjects.manage.access;subjects.create"
        policy.save_changes
        post "/courses-manage/subject", { "name" => "Computer Science" }, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:error]).to eq("Subject with provided name already exist.")
      end
    end

    context "when provider name contains special characters" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "provide_subjects")
        policy.permissions = "subjects.manage.access;subjects.create"
        policy.save_changes
        post "/courses-manage/subject", { "name" => "Test providerr%" }, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:error]).to eq("You cannot put any special characters in subject name.")
      end
    end

    context "when subject name is empty" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "provide_subjects")
        policy.permissions = "subjects.manage.access;subjects.create"
        policy.save_changes
        post "/courses-manage/subject", { "name" => "" }, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:error]).to eq("Something went wrong. Cannot create a subject.")
      end
    end

    context "when all params are valid and user has permissions" do
      it "creates subject successfully" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "provide_subjects")
        policy.permissions = "subjects.manage.access;subjects.create"
        policy.save_changes
        post "/courses-manage/subject", { "name" => "Test subject" }, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:info]).to eq("Subject with name: Test subject has been successfully created.")
      end
    end
  end

  describe "DELETE /courses-manage/subject" do
    context "when user is not logged in" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        delete "/courses-manage/subject"
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/login")
        expect(session[:error]).to eq("You must be logged in to access this site.")
      end
    end

    context "when user has no permissions to access site" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        delete "/courses-manage/subject", {}, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/")
        expect(session[:error]).to eq("Access denied. You don't have enough permissions to access this site.")
      end
    end

    context "when user has no permissions to delete providers" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "manage_subjects")
        policy.permissions = "courses.manage.access"
        policy.save_changes
        delete "/courses-manage/subject", {}, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:error]).to eq("You don't have enough permissions to delete a subject.")
      end
    end

    context "when provider with that id does not exist" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "manage_subjects")
        policy.permissions = "courses.manage.access;subjects.delete"
        policy.save_changes
        delete "/courses-manage/subject", { "subject" => "20" }, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:error]).to eq("It seems that selected subject does not exist.")
      end
    end

    context "when all params are valid and user has permissions" do
      it "deletes provider successfully" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "manage_subjects")
        policy.permissions = "courses.manage.access;subjects.delete"
        policy.save_changes
        delete "/courses-manage/subject", { "subject" => "1" }, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:info]).to eq("Subject has been successfully deleted.")
      end
    end
  end

  describe "PUT /courses-manage/subject" do
    context "when user is not logged in" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        put "/courses-manage/subject"
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/login")
        expect(session[:error]).to eq("You must be logged in to access this site.")
      end
    end

    context "when user has no permissions to access site" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        put "/courses-manage/subject", {}, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/")
        expect(session[:error]).to eq("Access denied. You don't have enough permissions to access this site.")
      end
    end

    context "when user has no permissions to create providers" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "manage_subjects")
        policy.permissions = "courses.manage.access"
        policy.save_changes
        put "/courses-manage/subject", {}, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:error]).to eq("You don't have enough permissions to edit a subject.")
      end
    end

    context "when selected provider does not exist" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "manage_subjects")
        policy.permissions = "courses.manage.access;subjects.edit"
        policy.save_changes
        put "/courses-manage/subject", { "subject" => "100" }, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:error]).to eq("You must select a subject you want to edit.")
      end
    end

    context "when provider with that name already exist" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "manage_subjects")
        policy.permissions = "courses.manage.access;subjects.edit"
        policy.save_changes
        put "/courses-manage/subject", { "subject" => "2", "name" => "Computer Science" }, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:error]).to eq("Subject with provided name already exist.")
      end
    end

    context "when provider name contains special characters" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "manage_subjects")
        policy.permissions = "courses.manage.access;subjects.edit"
        policy.save_changes
        put "/courses-manage/subject", { "subject" => "2", "name" => "Test subject%" }, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:error]).to eq("You cannot put any special characters in subject name.")
      end
    end

    context "when provider name is empty" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "manage_subjects")
        policy.permissions = "courses.manage.access;subjects.edit"
        policy.save_changes
        put "/courses-manage/subject", { "subject" => "2", "name" => "" }, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:error]).to eq("Something went wrong. Cannot edit selected course.")
      end
    end

    context "when all params are valid and user has permissions" do
      it "creates provider successfully" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "manage_subjects")
        policy.permissions = "courses.manage.access;subjects.edit"
        policy.save_changes
        put "/courses-manage/subject", { "subject" => "1", "name" => "Test subject" }, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:info]).to eq("Subject has been successfully edited.")
      end
    end
  end

  #=======================

  describe "POST /courses-manage/tags-category" do
    context "when user is not logged in" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        post "/courses-manage/tags-category"
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/login")
        expect(session[:error]).to eq("You must be logged in to access this site.")
      end
    end

    context "when user has no permissions to access site" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        post "/courses-manage/tags-category", {}, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/")
        expect(session[:error]).to eq("Access denied. You don't have enough permissions to access this site.")
      end
    end

    context "when user has no permissions to create tags categories" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "provide_tags_categories")
        policy.permissions = "courses.manage.access"
        policy.save_changes
        post "/courses-manage/tags-category", {}, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:error]).to eq("You don't have enough permissions to create a tag category.")
      end
    end

    context "when tag category with that name already exist" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "provide_tags_categories")
        policy.permissions = "courses.manage.access;tags.category.create"
        policy.save_changes
        post "/courses-manage/tags-category", { "name" => "level" }, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:error]).to eq("Tag category with provided name already exist.")
      end
    end

    context "when tag category name contains special characters" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "provide_tags_categories")
        policy.permissions = "courses.manage.access;tags.category.create"
        policy.save_changes
        post "/courses-manage/tags-category", { "name" => "Test category%" }, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:error]).to eq("You cannot put any special characters in tag category name.")
      end
    end

    context "when tags category name is empty" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "provide_tags_categories")
        policy.permissions = "courses.manage.access;tags.category.create"
        policy.save_changes
        post "/courses-manage/tags-category", { "name" => "" }, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:error]).to eq("Something went wrong. Cannot create a tag category.")
      end
    end

    context "when all params are valid and user has permissions" do
      it "creates tags category successfully" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "provide_tags_categories")
        policy.permissions = "courses.manage.access;tags.category.create"
        policy.save_changes
        post "/courses-manage/tags-category", { "name" => "Test tag category" }, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:info]).to eq("Tag category with name: Test tag category has been successfully created.")
      end
    end
  end

  describe "DELETE /courses-manage/tags-category" do
    context "when user is not logged in" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        delete "/courses-manage/tags-category"
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/login")
        expect(session[:error]).to eq("You must be logged in to access this site.")
      end
    end

    context "when user has no permissions to access site" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        delete "/courses-manage/tags-category", {}, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/")
        expect(session[:error]).to eq("Access denied. You don't have enough permissions to access this site.")
      end
    end

    context "when user has no permissions to delete tags categories" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "manage_tags_categories")
        policy.permissions = "courses.manage.access"
        policy.save_changes
        delete "/courses-manage/tags-category", {}, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:error]).to eq("You don't have enough permissions to delete a tag category.")
      end
    end

    context "when provider with that id does not exist" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "manage_tags_categories")
        policy.permissions = "courses.manage.access;tags.category.delete"
        policy.save_changes
        delete "/courses-manage/tags-category", { "tags-category" => "something" }, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:error]).to eq("It seems that selected tag category does not exist.")
      end
    end

    context "when all params are valid and user has permissions" do
      it "deletes tag category successfully" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "manage_tags_categories")
        policy.permissions = "courses.manage.access;tags.category.delete"
        policy.save_changes
        delete "/courses-manage/tags-category", { "tags-category" => "level" }, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:info]).to eq("Tag category has been successfully deleted.")
      end
    end
  end

  describe "PUT /courses-manage/tags-category" do
    context "when user is not logged in" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        put "/courses-manage/tags-category"
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/login")
        expect(session[:error]).to eq("You must be logged in to access this site.")
      end
    end

    context "when user has no permissions to access site" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        put "/courses-manage/tags-category", {}, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/")
        expect(session[:error]).to eq("Access denied. You don't have enough permissions to access this site.")
      end
    end

    context "when user has no permissions to create providers" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "manage_tags_categories")
        policy.permissions = "courses.manage.access"
        policy.save_changes
        put "/courses-manage/tags-category", {}, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:error]).to eq("You don't have enough permissions to edit a tag category.")
      end
    end

    context "when selected provider does not exist" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "manage_tags_categories")
        policy.permissions = "courses.manage.access;tags.category.edit"
        policy.save_changes
        put "/courses-manage/tags-category", { "tags-category" => "something" }, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:error]).to eq("You must select a tag category you want to edit.")
      end
    end

    context "when provider with that name already exist" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "manage_tags_categories")
        policy.permissions = "courses.manage.access;tags.category.edit"
        policy.save_changes
        put "/courses-manage/tags-category", { "tags-category" => "level", "name" => "topic" }, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:error]).to eq("Tag category with provided name already exist.")
      end
    end

    context "when provider name contains special characters" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "manage_tags_categories")
        policy.permissions = "courses.manage.access;tags.category.edit"
        policy.save_changes
        put "/courses-manage/tags-category", { "tags-category" => "level", "name" => "Test category%" }, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:error]).to eq("You cannot put any special characters in tag category name.")
      end
    end

    context "when provider name is empty" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "manage_tags_categories")
        policy.permissions = "courses.manage.access;tags.category.edit"
        policy.save_changes
        put "/courses-manage/tags-category", { "tags-category" => "level", "name" => "" }, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:error]).to eq("Something went wrong. Cannot edit selected tag category.")
      end
    end

    context "when all params are valid and user has permissions" do
      it "creates provider successfully" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "manage_tags_categories")
        policy.permissions = "courses.manage.access;tags.category.edit"
        policy.save_changes
        put "/courses-manage/tags-category", { "tags-category" => "level", "name" => "Test category" }, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:info]).to eq("Tag category with name: Test category has been successfully edited.")
      end
    end
  end

  #=============================================

  describe "POST /courses-manage/:tag" do
    context "when user is not logged in" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        post "/courses-manage/tag-level"
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/login")
        expect(session[:error]).to eq("You must be logged in to access this site.")
      end
    end

    context "when user has no permissions to access site" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        post "/courses-manage/tag-level", {}, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/")
        expect(session[:error]).to eq("Access denied. You don't have enough permissions to access this site.")
      end
    end

    context "when user has no permissions to create tags categories" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "provide_tags")
        policy.permissions = "courses.manage.access"
        policy.save_changes
        post "/courses-manage/tag-level", {}, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:error]).to eq("You don't have enough permissions to create a tag.")
      end
    end

    context "when tag category with that name already exist" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "provide_tags")
        policy.permissions = "courses.manage.access;tags.create"
        policy.save_changes
        post "/courses-manage/tag-level", { "name" => "intermediate" }, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:error]).to eq("Level tag with provided name already exist.")
      end
    end

    context "when tag category which we want to add tag to does not exist" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "provide_tags")
        policy.permissions = "courses.manage.access;tags.create"
        policy.save_changes
        post "/courses-manage/tag-something", { "name" => "Test tag" }, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:error]).to eq("It seems that tag category you're trying to add tag to does not exist.")
      end
    end

    context "when tag category name contains special characters" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "provide_tags")
        policy.permissions = "courses.manage.access;tags.create"
        policy.save_changes
        post "/courses-manage/tag-level", { "name" => "Test tag%" }, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:error]).to eq("You cannot put any special characters in tag name.")
      end
    end

    context "when tags category name is empty" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "provide_tags")
        policy.permissions = "courses.manage.access;tags.create"
        policy.save_changes
        post "/courses-manage/tag-level", { "name" => "" }, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:error]).to eq("Something went wrong. Cannot create a tag.")
      end
    end

    context "when all params are valid and user has permissions" do
      it "creates tags category successfully" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "provide_tags")
        policy.permissions = "courses.manage.access;tags.create"
        policy.save_changes
        post "/courses-manage/tag-level", { "name" => "Test tag" }, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:info]).to eq("Level tag with name: Test tag has been successfully created.")
      end
    end
  end

  describe "DELETE /courses-manage/:tag" do
    context "when user is not logged in" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        delete "/courses-manage/tag-level"
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/login")
        expect(session[:error]).to eq("You must be logged in to access this site.")
      end
    end

    context "when user has no permissions to access site" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        delete "/courses-manage/tag-level", {}, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/")
        expect(session[:error]).to eq("Access denied. You don't have enough permissions to access this site.")
      end
    end

    context "when user has no permissions to delete tags categories" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "manage_tags")
        policy.permissions = "courses.manage.access"
        policy.save_changes
        delete "/courses-manage/tag-level", {}, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:error]).to eq("You don't have enough permissions to delete tags.")
      end
    end

    context "when provider with that id does not exist" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "manage_tags")
        policy.permissions = "courses.manage.access;tags.delete"
        policy.save_changes
        delete "/courses-manage/tag-level", { "tag-level" => "100" }, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:error]).to eq("It seems that selected level does not exist.")
      end
    end

    context "when all params are valid and user has permissions" do
      it "deletes tag category successfully" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "manage_tags")
        policy.permissions = "courses.manage.access;tags.delete"
        policy.save_changes
        delete "/courses-manage/tag-level", { "tag-level" => "1" }, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:info]).to eq("Selected level tag has been successfully deleted.")
      end
    end
  end

  describe "PUT /courses-manage/:tag" do
    context "when user is not logged in" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        put "/courses-manage/tag-level"
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/login")
        expect(session[:error]).to eq("You must be logged in to access this site.")
      end
    end

    context "when user has no permissions to access site" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        put "/courses-manage/tag-level", {}, { "rack.session" => { id: 1 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/")
        expect(session[:error]).to eq("Access denied. You don't have enough permissions to access this site.")
      end
    end

    context "when user has no permissions to create providers" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "manage_tags")
        policy.permissions = "courses.manage.access"
        policy.save_changes
        put "/courses-manage/tag-level", {}, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:error]).to eq("You don't have enough permissions to create a tag.")
      end
    end

    context "when selected provider does not exist" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "manage_tags")
        policy.permissions = "courses.manage.access;tags.edit"
        policy.save_changes
        put "/courses-manage/tag-level", { "tag-level" => "100" }, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:error]).to eq("It seems that selected level tag does not exist.")
      end
    end

    context "when provider with that name already exist" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "manage_tags")
        policy.permissions = "courses.manage.access;tags.edit"
        policy.save_changes
        put "/courses-manage/tag-level", { "tag-level" => "1", "name" => "intermediate" }, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:error]).to eq("Level tag with provided name already exists.")
      end
    end

    context "when provider name contains special characters" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "manage_tags")
        policy.permissions = "courses.manage.access;tags.edit"
        policy.save_changes
        put "/courses-manage/tag-level", { "tag-level" => "1", "name" => "Test tag%" }, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:error]).to eq("You cannot put any special characters in tag name.")
      end
    end

    context "when provider name is empty" do
      it "gives an error" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "manage_tags")
        policy.permissions = "courses.manage.access;tags.edit"
        policy.save_changes
        put "/courses-manage/tag-level", { "tag-level" => "1", "name" => "" }, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:error]).to eq("Something went wrong. Cannot edit selected level tag.")
      end
    end

    context "when all params are valid and user has permissions" do
      it "creates provider successfully" do
        DbHelper.set_main_tables(true, true)
        policy = Policy.first(name: "manage_tags")
        policy.permissions = "courses.manage.access;tags.edit"
        policy.save_changes
        put "/courses-manage/tag-level", { "tag-level" => "1", "name" => "Test tag" }, { "rack.session" => { id: 3 } }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq("http://example.org/courses-manage")
        expect(session[:info]).to eq("Level tag has been successfully edited.")
      end
    end
  end
end
