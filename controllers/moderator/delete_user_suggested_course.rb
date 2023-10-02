post "/delete-suggested-course" do
  # Verify permissions to view the page.
  @logged_user = User.first(id: session[:id])

  if @logged_user.nil?
    session[:error] = "You must be logged in to access this site."
    redirect "/login"
  elsif !@logged_user.permission?("suggested_courses.manage")
    session[:error] = "Access denied. You don't have enough permissions to access this site."
    redirect "/"
  end

  suggested_course_id = params["id"]
  suggested_course = User_suggested_course.first(id: suggested_course_id)
  # delete the suggested course record
  suggested_course.delete
  redirect "/user-suggested-courses"

  @title = "Suggested courses"
  erb :'pages/moderator/delete_user_suggested_course'
end
