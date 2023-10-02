require_relative "../../spec_helper"

describe "LOGGING IN A USER (UNIT TEST)" do
  # Setup user
  email = "#{SecureRandom.hex}@abc.com"
  password = "#{SecureRandom.hex}1*$"
  new_user = User.new
  new_user.register(email, password)
  new_user.save_changes

  it "Logs in a user in the database successfully" do
    new_user = User.new
    login_success = new_user.login(email, password)
    expect(login_success)
  end

  it "Logs in a user in the database unsuccessfully" do
    new_user = User.new
    login_success = new_user.login(email, "#{password}abc")
    expect(!login_success)
  end
end

describe "Logging in a user (END TO END TEST)" do
  email = "#{SecureRandom.hex}@abc.com"
  password = "#{SecureRandom.hex}1*$"
  new_user = User.new
  new_user.register(email, password)
  new_user.save_changes

  context "GET /login" do
    it "Gets the login page" do
      get "/login"
      expect(last_response.body).to include("Login")
    end
  end

  context "POST /login" do
    it "Logs in a user successfully" do
      post "/login", email: email, password: password
      expect(last_response.status == 302 && last_response['Location'] == "http://example.org/")
    end

    it "Email is not input into field" do
      post "/login", "email" => "", "password" => "&63HXdq*YzF8$H"
      expect(last_response.body).to include("Email needs to be entered")
    end

    it "Passwords is not input into field" do
      post "/login", :email => email, "password" => ""
      expect(last_response.body).to include("Password needs to be entered")
    end
  end
end
