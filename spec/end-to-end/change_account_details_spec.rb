require_relative "../spec_helper"

describe "change account details page" do
  new_email = "#{SecureRandom.hex}@abc.com"
  new_email2 = "#{SecureRandom.hex}@abc.com"
  new_password = "#{SecureRandom.hex}1*$"
  new_password2 = "#{SecureRandom.hex}1*$"

  it "displays an error if there is an existing email" do
    UsersDbHelper2.reset
    UsersDbHelper2.create_many_users
    login "test1@gmail.com", "Test!!123"
    visit "/account-details"
    # store the second user's record in a variable.
    user2 = User.first(id: 2)
    fill_in "email_change", with: user2.email
    fill_in "email_change_confirmation", with: user2.email
    click_button "submit-email"
    expect(page).to have_content "Email already exists, please try another email."
  end

  it "displays error when different emails are input" do
    UsersDbHelper2.reset
    UsersDbHelper2.create_user
    login "test1@gmail.com", "Test!!123"
    visit "/account-details"
    fill_in "email_change", with: new_email
    fill_in "email_change_confirmation", with: new_email2
    click_button "submit-email"
    expect(page).to have_content "Your email does not match"
  end

  it "displays error when different passwords are input" do
    UsersDbHelper2.reset
    UsersDbHelper2.create_user
    login "test1@gmail.com", "Test!!123"
    visit "/account-details"
    fill_in "password_change", with: new_password
    fill_in "password_change_confirmation", with: new_password2
    click_button "submit-password"
    expect(page).to have_content "Your password does not match"
  end

  it "displays error when 'change email' field is empty" do
    UsersDbHelper2.reset
    UsersDbHelper2.create_user
    login "test1@gmail.com", "Test!!123"
    visit "/account-details"
    fill_in "email_change_confirmation", with: new_email
    click_button "submit-email"
    expect(page).to have_content "Please fill out the 'change email' field"
  end

  it "displays error when 're-enter email' field is empty" do
    UsersDbHelper2.reset
    UsersDbHelper2.create_user
    login "test1@gmail.com", "Test!!123"
    visit "/account-details"
    fill_in "email_change", with: new_email
    click_button "submit-email"
    expect(page).to have_content "Please fill out the 're-enter email' field"
  end

  it "displays error when 'change password' field is empty" do
    UsersDbHelper2.reset
    UsersDbHelper2.create_user
    login "test1@gmail.com", "Test!!123"
    visit "/account-details"
    fill_in "password_change_confirmation", with: new_password
    click_button "submit-password"
    expect(page).to have_content "Please fill out the 'change password' field"
  end

  it "displays error when 're-enter password' field is empty" do
    UsersDbHelper2.reset
    UsersDbHelper2.create_user
    login "test1@gmail.com", "Test!!123"
    visit "/account-details"
    fill_in "password_change", with: new_password
    click_button "submit-password"
    expect(page).to have_content "Please fill out the 're-enter password' field"
  end

  it "displays success when change email fields are correct" do
    UsersDbHelper2.reset
    UsersDbHelper2.create_user
    login "test1@gmail.com", "Test!!123"
    visit "/account-details"
    fill_in "email_change", with: new_email
    fill_in "email_change_confirmation", with: new_email
    click_button "submit-email"
    expect(page).to have_content "Email has been changed successfully"
  end

  it "displays success when change password fields are correct" do
    UsersDbHelper2.reset
    UsersDbHelper2.create_user
    login "test1@gmail.com", "Test!!123"
    visit "/account-details"
    fill_in "password_change", with: new_password
    fill_in "password_change_confirmation", with: new_password
    click_button "submit-password"
    expect(page).to have_content "Password has been changed successfully"
  end

  it "displays error when email format is invalid" do
    UsersDbHelper2.reset
    UsersDbHelper2.create_user
    login "test1@gmail.com", "Test!!123"
    visit "/account-details"
    fill_in "email_change", with: "changingemail"
    fill_in "email_change_confirmation", with: "changingemail"
    click_button "submit-email"
    expect(page).to have_content "Please enter a valid email address."
  end

  it "displays error when password is too weak" do
    UsersDbHelper2.reset
    UsersDbHelper2.create_user
    login "test1@gmail.com", "Test!!123"
    visit "/account-details"
    fill_in "password_change", with: "changingpassword"
    fill_in "password_change_confirmation", with: "changingpassword"
    click_button "submit-password"
    expect(page).to have_content "Password is not strong enough: password of 8 characters, minimum one upper, lower case letter, special character and number"
  end
end
