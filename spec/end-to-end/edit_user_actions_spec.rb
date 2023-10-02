# End to end tests for actions on the edit user page.
require_relative "../spec_helper"

describe "performing actions on edit user page" do
  it "returns an error if changing the name has anything than spaces and letters" do
    UsersDbHelper2.reset
    UsersDbHelper2.create_user
    UsersDbHelper2.create_administrator

    login "admin@gmail.com", "Test!!123"

    visit "/edit-user?id=1"
    fill_in "first_name", with: "Test12345"
    click_button "Submit"
    expect(page).to have_content "First name can only contain letters and spaces."
  end

  it "returns an error if an invalid email is entered" do
    UsersDbHelper2.reset
    UsersDbHelper2.create_user
    UsersDbHelper2.create_administrator

    login "admin@gmail.com", "Test!!123"

    visit "/edit-user?id=1"
    fill_in "email", with: "test123"
    click_button "Submit"
    expect(page).to have_content "Please enter a valid email address."
  end

  it "returns an error if an invalid year of study value has been entered" do
    UsersDbHelper2.reset
    UsersDbHelper2.create_user
    UsersDbHelper2.create_administrator

    login "admin@gmail.com", "Test!!123"

    visit "/edit-user?id=1"
    fill_in "year_of_study", with: 8
    click_button "Submit"
    expect(page).to have_content "Year of study must be between 1 to 6."
  end

  it "returns an error if there are no roles checked" do
    UsersDbHelper2.reset
    UsersDbHelper2.create_user
    UsersDbHelper2.create_administrator

    login "admin@gmail.com", "Test!!123"

    visit "/edit-user?id=1"
    find_by_id('role1').set(false)
    click_button "Submit"
    expect(page).to have_content "Please set at least one role."
  end

  it "returns an error if there are no roles checked when on staff user profile" do
    UsersDbHelper2.reset
    UsersDbHelper2.create_many_users
    UsersDbHelper2.create_administrator

    login "admin@gmail.com", "Test!!123"

    visit "/edit-user?id=2"
    find_by_id('role3').set(false)
    find_by_id('role4').set(false)
    find_by_id('role5').set(false)
    click_button "Submit"
    expect(page).to have_content "Please set at least one role."
  end

  it "makes changes to all fields successfully" do
    UsersDbHelper2.reset
    UsersDbHelper2.create_user
    UsersDbHelper2.create_administrator

    login "admin@gmail.com", "Test!!123"

    # create another subject to change to
    subject2 = Subject.new(name: "Another")
    subject2.save_changes

    visit "/edit-user?id=1"
    fill_in "first_name", with: "Bob"
    fill_in "last_name", with: "Harrison"
    select "Another", from: "subject"
    fill_in "year_of_study", with: 3
    fill_in "email", with: "test2@gmail.com"
    find_by_id('role2').set(true)
    click_button "Submit"
    expect(page).to have_content "Data has been successfully updated."
  end

  it "deletes user data successfully" do
    UsersDbHelper2.reset
    UsersDbHelper2.create_user
    UsersDbHelper2.create_administrator

    login "admin@gmail.com", "Test!!123"

    visit "/edit-user?id=1"
    click_button "Delete"
    # redirects to user list page
    expect(page).to have_content "List of All Users"
  end
end
