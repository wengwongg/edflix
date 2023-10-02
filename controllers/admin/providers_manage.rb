get "/providers-manage" do
  @logged_user = User.first(id: session[:id])

  if @logged_user.nil?
    session[:error] = "You must be logged in to access this site."
    redirect "/login"
  elsif !@logged_user.permission?("providers.manage.access")
    session[:error] = "Access denied. You don't have enough permissions to access this site."
    redirect "/"
  end

  @title = "Manage providers"
  erb :'pages/admin/providers_manage', layout: :'templates/layout'
end

post "/providers-manage/provider" do
  @logged_user = User.first(id: session[:id])
  @provider = Provider.first(name: params['name'])

  if @logged_user.nil?
    session[:error] = "You must be logged in to access this site."
    redirect "/login"
  elsif !@logged_user.permission?("providers.manage.access")
    session[:error] = "Access denied. You don't have enough permissions to access this site."
    redirect "/"
  elsif !@logged_user.permission?("providers.create")
    error = "You don't have enough permissions to create providers."
  elsif !@provider.nil?
    error = "Provider with provided name already exist."
  elsif Validation.str_has_special_chars?(params['name'])
    error = "You cannot put any special characters in provider name."
  elsif !Provider.create(params['name'])
    error = "Something went wrong. Cannot create a provider."
  else
    session[:info] = "Provider with name: #{params['name']} has been successfully created."
  end
  session[:error] = error unless error.nil?

  redirect "/providers-manage"
end

delete "/providers-manage/provider" do
  @logged_user = User.first(id: session[:id])
  @provider = Provider.first(id: params['provider'])

  if @logged_user.nil?
    session[:error] = "You must be logged in to access this site."
    redirect "/login"
  elsif !@logged_user.permission?("providers.manage.access")
    session[:error] = "Access denied. You don't have enough permissions to access this site."
    redirect "/"
  elsif !@logged_user.permission?("providers.delete")
    error = "You don't have enough permissions to delete a provider."
  elsif @provider.nil?
    error = "It seems that selected provider does not exist."
  else
    @provider.delete
    session[:info] = "Provider has been successfully deleted."
  end
  session[:error] = error unless error.nil?

  redirect "/providers-manage"
end

put "/providers-manage/provider" do
  @logged_user = User.first(id: session[:id])
  @provider = Provider.first(id: params['provider'])
  other_provider = Provider.first(name: params['name'])

  if @logged_user.nil?
    session[:error] = "You must be logged in to access this site."
    redirect "/login"
  elsif !@logged_user.permission?("providers.manage.access")
    session[:error] = "Access denied. You don't have enough permissions to access this site."
    redirect "/"
  elsif !@logged_user.permission?("providers.edit")
    error = "You don't have enough permissions to edit a provider."
  elsif @provider.nil?
    error = "You must select a provider you want to edit."
  elsif !other_provider.nil?
    error = "Provider with provided name already exist."
  elsif Validation.str_has_special_chars?(params['name'])
    error = "You cannot put any special characters in provider name."
  elsif !@provider.change_name(params['name'])
    error = "Something went wrong. Cannot edit selected provider."
  else
    session[:info] = "Provider has been successfully edited."
  end
  session[:error] = error unless error.nil?

  redirect "/providers-manage"
end
