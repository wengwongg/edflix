require_relative "../spec_helper"

describe "errors when logging in as suspended/deleted user" do

  it "gives an error when trying to log in as suspended user" do
    UsersDbHelper2.reset
    UsersDbHelper2.create_user
    
    # set the user as suspended
    user = User.first(id: 1)
    user.is_suspended = 1
    user.save_changes

    visit "/login"
    fill_in "email", with: "test1@gmail.com"
    fill_in "password", with: "Test!!123"
    click_button "Login"
    expect(page).to have_content("You cannot log in. Your account has been suspended or deleted.")
  end

  it "gives an error when trying to log in as deleted user" do
    UsersDbHelper2.reset
    UsersDbHelper2.create_user
    
    # set the user as suspended
    user = User.first(id: 1)
    user.is_deleted = 1
    user.save_changes

    visit "/login"
    fill_in "email", with: "test1@gmail.com"
    fill_in "password", with: "Test!!123"
    click_button "Login"
    expect(page).to have_content("You cannot log in. Your account has been suspended or deleted.")
  end

end