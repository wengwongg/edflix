post "/delete-user" do
  # Verify permissions to view the page.
  @logged_user = User.first(id: session[:id])

  if @logged_user.nil?
    session[:error] = "You must be logged in to access this site."
    redirect "/login"
  elsif !@logged_user.permission?("users.manage.access")
    session[:error] = "Access denied. You don't have enough permissions to access this site."
    redirect "/"
  end

  user_id = params["id"]
  user = User.first(id: user_id)
  user_info = User_info.first(user_id: user_id)
  # delete the user info record
  user_info.delete
  # delete the user record
  user.delete
  redirect "/user-list"
end
