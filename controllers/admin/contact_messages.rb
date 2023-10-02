get "/messages" do
  @logged_user = User.first(id: session[:id])

  if @logged_user.nil?
    session[:error] = "You must be logged in to access this site."
    redirect "/login"
  elsif !@logged_user.permission?("messages.manage.access")
    session[:error] = "You don't have enough permissions to access this site."
    redirect "/"
  end

  @pagination = PaginatedArray.new(StaffContact.latest_messages, params)
  @title = "User messages"
  erb :'pages/admin/user_messages', layout: :'templates/layout'
end

delete "/messages/:id" do
  @logged_user = User.first(id: session[:id])
  @message = StaffContact.first(id: params['id'])

  if @logged_user.nil?
    session[:error] = "You must be logged in to access this site."
    redirect "/login"
  elsif !@logged_user.permission?("messages.delete")
    session[:error] = "You don't have enough permissions to access this site."
    redirect "/"
  elsif @message.nil?
    session[:error] = "Message you're trying to delete does not exist."
  else
    @message.delete
    session[:info] = "Message was deleted successfully."
  end

  redirect "/messages"
end