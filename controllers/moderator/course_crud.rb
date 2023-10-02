get "/courses/:id/edit" do
  @course = Course.first(id: params['id'])
  @logged_user = User.first(id: session[:id])

  if @logged_user.nil?
    session[:error] = "You must be logged in to access this site."
    redirect "/login"
  elsif @course.nil?
    error = "Course you're trying to access does not exist"
  elsif !@logged_user.permission?("courses.edit") ||
        !(@logged_user.provider?(@course.provider) || @logged_user.permission?("courses.edit.all"))
    error = "Access denied. You don't have enough permissions to access this site."
  end

  unless error.nil?
    session[:error] = error
    redirect "/courses"
  end

  @title = "Edit course"
  erb :'pages/moderator/course_edit', layout: :'templates/layout'
end

post "/courses/:id/edit" do
  @course = Course.first(id: params['id'])
  @logged_user = User.first(id: session[:id])

  if @logged_user.nil?
    session[:error] = "You must be logged in to edit courses."
    redirect "/login"
  elsif @course.nil?
    error = "Course you're trying to edit does not exist"
  elsif !@logged_user.permission?("courses.edit") ||
        !(@logged_user.provider?(@course.provider) || @logged_user.permission?("courses.edit.all"))
    error = "Access denied. You don't have enough permissions to edit courses."
  elsif @logged_user.role_provider? && (params['provider'].nil? ||
    !@logged_user.providers.map { |provider| provider.id.to_s }.include?(params['provider']))
    params['provider'] = 0
  end

  unless error.nil?
    session[:error] = error
    redirect "/courses"
  end

  @course.course_load(params)
  if @course.valid?
    CourseViewer.create(CourseViewer.extract_viewers_from_params(params), @course.id)
    @course.save_changes
    session[:info] = "Course has been edited successfully."
    redirect "/courses/#{@course.id}/edit"
  end

  @title = "Edit course"
  erb :'pages/moderator/course_edit', layout: :'templates/layout'
end

delete "/courses/:id" do
  @current_user = User.first(id: session[:id])
  @course = Course.first(id: params['id'])
  if @current_user.nil?
    error = "You must be logged in to archive courses."
  elsif @course.nil?
    error = "Course of id: #{params['id']} does not exist!"
  elsif @course.archived?
    error = "Course of id: #{params['id']} is already archived."
  elsif !@current_user.nil?
    if !@current_user.permission?("courses.delete")
      error = "You don't have enough permissions to archive courses!"
    elsif !@current_user.provider?(@course.provider) && !@current_user.permission?("courses.delete.all")
      error = "You don't have enough permissions to archive this course!"
    else
      session[:info] = "Course has been successfully archived."
      @course.delete
    end
  end
  session[:error] = error

  redirect "/courses"
end

post "/courses/:id/restore" do
  @current_user = User.first(id: session[:id])
  @course = Course.first(id: params['id'])
  if @current_user.nil?
    error = "You must be logged in to restore courses."
  elsif @course.nil?
    error = "Course of id: #{params['id']} does not exist!"
  elsif !@course.archived?
    error = "Course of id: #{params['id']} has not been archived."
  elsif !@current_user.nil?
    if !@current_user.permission?("courses.delete")
      error = "You don't have enough permissions to restore courses!"
    elsif !@current_user.provider?(@course.provider) && !@current_user.permission?("courses.delete.all")
      error = "You don't have enough permissions to restore this course!"
    else
      session[:info] = "Course has been successfully restored."
      @course.restore
    end
  end
  session[:error] = error

  redirect "/courses"
end

get "/add-course" do
  @logged_user = User.first(id: session[:id])

  if @logged_user.nil?
    session[:error] = "You must be logged in to access this site."
    redirect "/login"
  elsif !@logged_user.permission?("courses.add")
    session[:error] = "Access denied. You don't have enough permissions to access this site."
    redirect "/courses"
  elsif @logged_user.role_provider? && @logged_user.providers.nil?
    session[:error] = "You cannot add courses until admin assigns you a provider name."
    redirect "/courses"
  end

  @title = "Create course"
  # creating a new Course instance
  @course = Course.new
  erb :'pages/moderator/course_create', layout: :'templates/layout'
end

post "/add-course" do
  @logged_user = User.first(id: session[:id])

  if @logged_user.nil?
    session[:error] = "You must be logged in to add courses."
    redirect "/login"
  elsif !@logged_user.permission?("courses.add")
    session[:error] = "Access denied. You don't have enough permissions to add courses."
    redirect "/courses"
  elsif @logged_user.role_provider?
    if @logged_user.providers.nil?
      session[:error] = "You cannot add courses until admin assigns you a provider name."
      redirect "/courses"
    elsif params['provider'].nil? ||
          !@logged_user.providers.map { |provider| provider.id.to_s }.include?(params['provider'])
      params['provider'] = 0
    end
  end

  @course = Course.new
  # setting form fields to table colums
  @course.course_load(params)

  if @course.valid?
    CourseViewer.create(CourseViewer.extract_viewers_from_params(params), @course.id)
    @course.save_changes
    session[:info] = "Course created successfully."
    redirect "/courses"
  end

  @title = "Create course"
  erb :'pages/moderator/course_create', layout: :'templates/layout'
end
