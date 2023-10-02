get "/user-suggested-courses" do
  # Verify permissions to view the page.
  @logged_user = User.first(id: session[:id])

  if @logged_user.nil?
    session[:error] = "You must be logged in to access this site."
    redirect "/login"
  elsif !@logged_user.permission?("suggested_courses.manage")
    session[:error] = "Access denied. You don't have enough permissions to access this site."
    redirect "/"
  end

  @user_suggested_courses = User_suggested_course.all

  @pagination = PaginatedArray.new(@user_suggested_courses, params)
  @user_suggested_courses = @pagination.paginated_array

  @title = "Suggested courses"
  erb :'pages/moderator/user_suggested_courses_list', layout: :'templates/layout'
end
