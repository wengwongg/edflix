require_relative '../spec_helper'

describe "managing own reviews" do
  context "when course does not exist" do
    it "gives an error when trying to add review" do
      DbHelper.set_main_tables(true, true)
      post "/courses/100/review", { "review_content" => "Some content", "review_stars" => "3" }, { "rack.session" => { id: 1 } }
      expect(last_response.status).to eq(302)
      expect(last_response.headers['Location']).to eq("http://example.org/courses")
      expect(session[:error]).to eq("Course of id 100 does not exist.")
    end

    it "gives an error when trying to delete review" do
      DbHelper.set_main_tables(true, true)
      delete "/courses/100/review", {}, { "rack.session" => { id: 1 } }
      expect(last_response.status).to eq(302)
      expect(last_response.headers['Location']).to eq("http://example.org/courses/100")
      expect(session[:error]).to eq("You cannot delete your review if it does not exist.")
    end
  end

  context "when passed data are invalid (example user_id does not exist)" do
    it "gives an error" do
      DbHelper.set_main_tables(true, true)
      post "/courses/1/review", { "review_content" => "Some content", "review_stars" => "0" }, { "rack.session" => { id: 1 } }
      expect(last_response.status).to eq(302)
      expect(last_response.headers['Location']).to eq("http://example.org/courses/1")
      expect(session[:error]).to eq("Something went wrong. Cannot save your review...")
    end
  end

  context "when user is not logged in" do
    it "does not display add/edit review form" do
      DbHelper.set_main_tables(true, true)
      visit "/courses/2"
      expect(page).not_to have_css("div#student-review")
    end

    it "gives an error when trying to add review" do
      DbHelper.set_main_tables(true, true)
      post "/courses/1/review", { "review_content" => "Some content", "review_stars" => "3" }
      expect(last_response.status).to eq(302)
      expect(last_response.headers['Location']).to eq("http://example.org/courses/1")
      expect(session[:error]).to eq("You must be logged in to add a review.")
    end

    it "gives an error when trying to delete review" do
      DbHelper.set_main_tables(true, true)
      delete "/courses/1/review", {}
      expect(last_response.status).to eq(302)
      expect(last_response.headers['Location']).to eq("http://example.org/courses/1")
      expect(session[:error]).to eq("You must be logged in to delete a review.")
    end
  end

  context "when user logged in has no permissions to add reviews" do
    it "does not display add/edit review form" do
      DbHelper.set_main_tables(true, true)
      login "test@test.eu", "P4$$word"
      visit "/courses/2"
      expect(page).not_to have_css("div#student-review")
    end

    it "gives an error when trying to add review" do
      DbHelper.set_main_tables(true, true)
      post "/courses/1/review", { "review_content" => "Some content", "review_stars" => "3" }, { "rack.session" => { id: 2 } }
      expect(last_response.status).to eq(302)
      expect(last_response.headers['Location']).to eq("http://example.org/courses/1")
      expect(session[:error]).to eq("You don't have enough permissions to add reviews.")
    end

    it "gives an error when trying to delete review" do
      DbHelper.set_main_tables(true, true)
      delete "/courses/1/review", {}, { "rack.session" => { id: 2 } }
      expect(last_response.status).to eq(302)
      expect(last_response.headers['Location']).to eq("http://example.org/courses/1")
      expect(session[:error]).to eq("You don't have enough permissions to delete your reviews.")
    end
  end

  context "when user logged in has permissions to add reviews" do
    it "displays add/edit review form" do
      DbHelper.set_main_tables(true, true)
      login "test2@test.eu", "P4$$word"
      visit "/courses/2"
      expect(page).to have_css("div#student-review")
    end

    it "review form should be empty if logged user has no reviews" do
      DbHelper.set_main_tables(true, true)
      ReviewsDbHelper.reset
      login "test2@test.eu", "P4$$word"
      visit "/courses/2"
      expect(page).not_to have_css("i#review-star-1.fa-solid.fa-star.checked")
    end

    it "delete button should not show up if logged user has no reviews" do
      DbHelper.set_main_tables(true, true)
      ReviewsDbHelper.reset
      login "test2@test.eu", "P4$$word"
      visit "/courses/2"
      expect(page).not_to have_button("Delete")
    end

    it "review form should not be empty if logged user has a review" do
      DbHelper.set_main_tables(true, true)
      DbHelper.set_reviews
      login "test2@test.eu", "P4$$word"
      visit "/courses/2"
      expect(page).to have_css("i#review-star-1.fa-solid.fa-star.checked")
    end

    it "delete button should show up if logged user has a review" do
      DbHelper.set_main_tables(true, true)
      DbHelper.set_reviews
      login "test2@test.eu", "P4$$word"
      visit "/courses/2"
      expect(page).to have_button("Delete")
    end
  end

  context "when user has no review for particular course and wants to create one" do
    it "gives an error if rating (stars) is not chosen" do
      DbHelper.set_main_tables(true, true)
      ReviewsDbHelper.reset
      login "test2@test.eu", "P4$$word"
      visit "/courses/2"
      fill_in 'review_content', with: "some text"
      click_on "Save"

      expect(page).to have_current_path("/courses/2") && have_selector('h4.error') &&
                      have_content("You provided invalid rating.")
    end

    it "gives an error if content is empty" do
      DbHelper.set_main_tables(true, true)
      ReviewsDbHelper.reset
      login "test2@test.eu", "P4$$word"
      visit "/courses/2"
      find(:xpath, "//*[@id=\"student-review\"]/form[1]/div/div/div[3]/input").click
      click_on "Save"

      expect(page).to have_current_path("/courses/2") && have_selector('h4.error') &&
                      have_content("You must provide content of your review.")
    end

    it "adds review successfully" do
      DbHelper.set_main_tables(true, true)
      ReviewsDbHelper.reset
      login "test2@test.eu", "P4$$word"
      visit "/courses/2"
      find(:xpath, "//*[@id=\"student-review\"]/form[1]/div/div/div[3]/input").click
      fill_in 'review_content', with: "some text"
      click_on "Save"

      expect(page).to have_current_path("/courses/2") && have_selector('h4.info') &&
                      have_content("Your review has been saved.")
    end
  end

  context "when user is logged in and wants to delete a review" do
    it "deletes review succcessfully" do
      DbHelper.set_main_tables(true, true)
      DbHelper.set_reviews
      login "test2@test.eu", "P4$$word"
      visit "/courses/2"
      click_on "Delete"

      expect(page).to have_current_path("/courses/2") && have_selector('h4.info') &&
                        have_content("Your review has been deleted.")
    end
  end
end
