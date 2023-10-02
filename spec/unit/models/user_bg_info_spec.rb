require_relative '../../../app'
require_relative '../../spec_helper'

# tests for when landing initially on the page
RSpec.describe "user background information" do
  describe "GET/user_bg_info" do
    it "has a status code of 200 (OK)" do
      DbHelper.set_main_tables(false, true)
      get "/user_bg_info", {}, { "rack.session" => { id: 2 } }
      expect(last_response.status).to eq(200)
    end

    it "includes all the fields to update background information" do
      DbHelper.set_main_tables(false, true)
      get "/user_bg_info", {}, { "rack.session" => { id: 1 } }
      expect(last_response.body).to include("First Name")
      expect(last_response.body).to include("Last Name")
      expect(last_response.body).to include("Year of Study")
      expect(last_response.body).to include("Subject")
    end
  end

  # tests for when the user updates their background information
  describe 'POST/ user_bg_info' do
    it "rejects the form when first name field is not filled out" do
      DbHelper.set_main_tables(false, true)
      post "/user_bg_info", { "first_name" => "", "last_name" => "Doe",
                              "year_of_study" => "2", "subject" => "Computer Science" }, { "rack.session" => { id: 1 } }
      expect(last_response.body).to include("First name needs to be entered")
    end

    it "rejects the form when last name field is not filled out" do
      DbHelper.set_main_tables(false, true)
      post "/user_bg_info", { "first_name" => "John", "last_name" => "",
                              "year_of_study" => "2", "subject" => "Computer Science" }, { "rack.session" => { id: 1 } }
      expect(last_response.body).to include("Last name needs to be entered")
    end

    it "rejects the form when year of study is too little" do
      DbHelper.set_main_tables(false, true)
      post "/user_bg_info", { "first_name" => "John", "last_name" => "Doe",
                              "year_of_study" => "0", "subject" => "Computer Science" }, { "rack.session" => { id: 1 } }
      expect(last_response.body).to include("Please enter a year of study between 1 and 6")
    end

    it "rejects the form when year of study is too large" do
      DbHelper.set_main_tables(false, true)
      post "/user_bg_info", { "first_name" => "John", "last_name" => "Doe",
                              "year_of_study" => "7", "subject" => "Computer Science" }, { "rack.session" => { id: 1 } }
      expect(last_response.body).to include("Please enter a year of study between 1 and 6")
    end

    it "rejects the form when subject is not selected" do
      DbHelper.set_main_tables(false, true)
      post "/user_bg_info", { "first_name" => "John", "last_name" => "Doe",
                              "year_of_study" => "0", "subject" => "" }, { "rack.session" => { id: 1 } }
      expect(last_response.body).to include("Please select a subject from the list")
    end
  end
end
