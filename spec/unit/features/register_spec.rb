require_relative "../../spec_helper"
require 'securerandom'

describe "Registering a user (UNIT TEST)" do
  email = "#{SecureRandom.hex}@abc.com"
  password = "#{SecureRandom.hex}1*$"

  it "Registers a user in the database successfully" do
    new_user = User.new
    register_success = new_user.register(email, password)
    new_user.save_changes
    expect(register_success)
  end

  it "User already exists" do
    email = "#{SecureRandom.hex}@abc.com"
    password = "#{SecureRandom.hex}1*$"
    new_user = User.new
    register_success = new_user.register(email, password)
    new_user.save_changes

    # Create a new user with same email
    new_user_two = User.new
    register_success_two = new_user_two.register(email, password)

    expect(register_success && !register_success_two)
  end
end

describe "Registering a user (END TO END TEST)" do
  email = "#{SecureRandom.hex}@abc.com"
  password = "#{SecureRandom.hex}1*$"

  context "GET /register" do
    it "Gets the register page" do
      get "/register"
      expect(last_response.body).to include("Register")
    end
  end

  context "POST /register" do
    it "Registers a user successfully" do
      post "/register", email: email, password: password, confirm_password: password
      expect(last_response.status == 302 && last_response['Location'] == "http://example.org/login?register_success=true")
    end

    it "Email is not input into field" do
      post "/register", "email" => "", "password" => "&63HXdq*YzF8$H", "confirm_password" => "&63HXdq*YzF8$H"
      expect(last_response.body).to include("Email needs to be entered")
    end

    it "Password is not in the correct format" do
      post "/register", email: email, password: "badpassword", confirm_password: "badpassword"
      expect(last_response.body).to include("Password is not strong enough")
    end

    it "Passwords do not match" do
      # visit "/login"
      # fill_in "email", with: email
      # fill_in "password", with: password
      # fill_in "confirm_password", with: password + "H"
      # click_button "Register"
      # expect(page).to have_content "Passwords don't match"
      post "/register", email: email, password: password, confirm_password: "#{password}H"
      expect(last_response.body).to include("Passwords do not match")
    end

    it "Passwords is not input into field" do
      post "/register", :email => email, "password" => "", :confirm_password => password
      expect(last_response.body).to include("Password needs to be entered")
    end
  end
end
