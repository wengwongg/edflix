require_relative "../../spec_helper"

# No unit tests required for this module

describe "Forgot password of user (END TO END TEST)" do
  email = "#{SecureRandom.hex}@abc.com"
  password = "#{SecureRandom.hex}1*$"
  new_user = User.new
  new_user.register(email, password)
  new_user.save_changes

  context "GET /forgot-password" do
    it "Gets the forgot password page" do
      get "/forgot-password"
      expect(last_response.body).to include("Forgot Password")
    end
  end

  context "POST /forgot-password" do
    it "Forgot password successfully" do
      post "/forgot-password", email: email
      expect(last_response.status == 200 && last_response['Location'] == "http://example.org/")
    end

    it "Email is not input into field" do
      post "/forgot-password", "email" => ""
      expect(last_response.body).to include("Email needs to be filled")
    end
  end
end
