require_relative "../spec_helper"

describe "performing actions in the list of user suggested courses page" do
  it "deletes the user suggestion when delete button is clicked" do
    UsersDbHelper2.reset
    UsersDbHelper2.create_moderator

    # create a new suggested course
    new_suggested_course = User_suggested_course.new(user_id: 1, name: "Test Course", url: "https://google.com")
    new_suggested_course.save_changes

    login "moderator@gmail.com", "Test!!123"
    visit "/user-suggested-courses"

    click_button "Delete"
    # Nothing will be on the page.
    expect(page).to have_content "No courses have been suggested"
  end
end
