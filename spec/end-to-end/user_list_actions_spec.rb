# End-to-end testing for actions performed on user list page.
require_relative "../spec_helper"

describe "performing actions on user list page" do
  it "finds a specific email record successfully" do
    UsersDbHelper2.reset
    UsersDbHelper2.create_many_users
    UsersDbHelper2.create_administrator

    login "admin@gmail.com", "Test!!123"

    visit "/user-list"
    fill_in "email_filter", with: "test1@gmail.com"
    click_button "Filter"
    expect(page).to have_content "test1@gmail.com"
    expect(page).not_to have_content "test2@gmail.com"
    expect(page).not_to have_content "test3@gmail.com"
  end

  it "filters by subject successfully" do
    UsersDbHelper2.reset
    UsersDbHelper2.create_many_users
    UsersDbHelper2.create_administrator

    login "admin@gmail.com", "Test!!123"

    visit "/user-list"
    select "Another", from: "subject"
    click_button "Filter"
    expect(page).to have_content "test2@gmail.com"
    expect(page).not_to have_content "test1@gmail.com"
    expect(page).not_to have_content "test3@gmail.com"
  end

  it "filters by suspension status successfully" do
    UsersDbHelper2.reset
    UsersDbHelper2.create_many_users
    UsersDbHelper2.create_administrator

    login "admin@gmail.com", "Test!!123"

    visit "/user-list"
    select "Suspended", from: "suspension_filter"
    click_button "Filter"
    expect(page).to have_content "test3@gmail.com"
    expect(page).not_to have_content "test1@gmail.com"
    expect(page).not_to have_content "test2@gmail.com"
  end

  it "suspends a user successfully" do
    UsersDbHelper2.reset
    UsersDbHelper2.create_many_users
    UsersDbHelper2.create_administrator

    login "admin@gmail.com", "Test!!123"

    visit "/user-list"
    # Suspends the first user.
    click_button "suspend_button_1"

    # then filter by suspension
    select "Suspended", from: "suspension_filter"
    click_button "filter"
    expect(page).to have_content "test1@gmail.com"
    expect(page).to have_content "test3@gmail.com"
    expect(page).not_to have_content "test2@gmail.com"
  end

  it "redirects to edit page when trying to edit user" do
    UsersDbHelper2.reset
    UsersDbHelper2.create_many_users
    UsersDbHelper2.create_administrator

    login "admin@gmail.com", "Test!!123"

    visit "/user-list"
    # clicks on first edit button of first user
    find(:css, '#edit_1').click
    expect(page).to have_content "Edit User"
  end
end
