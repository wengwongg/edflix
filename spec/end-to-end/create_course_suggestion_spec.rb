require_relative "../spec_helper"

describe "performing actions on the suggest a course page" do
  it "returns an error when the name is empty" do
    UsersDbHelper2.reset
    UsersDbHelper2.create_user
    login "test1@gmail.com", "Test!!123"
    visit "/suggest-course"
    fill_in "course_url", with: "https://google.com"
    click_button "Submit"
    expect(page).to have_content "Course name field cannot be empty."
  end

  it "returns an error when the URL is empty" do
    UsersDbHelper2.reset
    UsersDbHelper2.create_user
    login "test1@gmail.com", "Test!!123"
    visit "/suggest-course"
    fill_in "course_name", with: "Test Course"
    click_button "Submit"
    expect(page).to have_content "URL field cannot be empty."
  end

  it "returns an error when the URL is not a proper URL" do
    UsersDbHelper2.reset
    UsersDbHelper2.create_user
    login "test1@gmail.com", "Test!!123"
    visit "/suggest-course"
    fill_in "course_name", with: "Test Course"
    fill_in "course_url", with: "invalidurl"
    click_button "Submit"
    expect(page).to have_content "Invalid URL entered, must be HTTPS/HTTP"
  end

  it "returns success when fields are submitted correctly" do
    UsersDbHelper2.reset
    UsersDbHelper2.create_user
    login "test1@gmail.com", "Test!!123"
    visit "/suggest-course"
    fill_in "course_name", with: "Test Course"
    fill_in "course_url", with: "https://google.com"
    click_button "Submit"
    expect(page).to have_content "Thank you for your suggestion. We will look into it further."
  end

  it "returns an error when you submit a suggestion more than 3 times in the same session" do
    UsersDbHelper2.reset
    UsersDbHelper2.create_user
    login "test1@gmail.com", "Test!!123"
    visit "/suggest-course"

    fill_in "course_name", with: "Test Course"
    fill_in "course_url", with: "https://google.com"
    click_button "Submit"

    fill_in "course_name", with: "Test Course"
    fill_in "course_url", with: "https://google.com"
    click_button "Submit"

    fill_in "course_name", with: "Test Course"
    fill_in "course_url", with: "https://google.com"
    click_button "Submit"

    fill_in "course_name", with: "Test Course"
    fill_in "course_url", with: "https://google.com"
    click_button "Submit"

    expect(page).to have_content "You cannot submit more than three submissions during the same session."
  end
end
