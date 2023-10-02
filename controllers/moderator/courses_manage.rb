get "/courses-manage" do
  @logged_user = User.first(id: session[:id])

  if @logged_user.nil?
    session[:error] = "You must be logged in to access this site."
    redirect "/login"
  elsif !@logged_user.permission?("courses.manage.access")
    session[:error] = "Access denied. You don't have enough permissions to access this site."
    redirect "/"
  end

  @title = "Manage course properties"
  erb :'pages/moderator/courses_manage', layout: :'templates/layout'
end

post "/courses-manage/subject" do
  @logged_user = User.first(id: session[:id])
  @subject = Subject.first(name: params['name'])

  if @logged_user.nil?
    session[:error] = "You must be logged in to access this site."
    redirect "/login"
  elsif !@logged_user.permission?("courses.manage.access")
    session[:error] = "Access denied. You don't have enough permissions to access this site."
    redirect "/"
  elsif !@logged_user.permission?("subjects.create")
    error = "You don't have enough permissions to create a subject."
  elsif !@subject.nil?
    error = "Subject with provided name already exist."
  elsif Validation.str_has_special_chars?(params['name'])
    error = "You cannot put any special characters in subject name."
  elsif !Subject.create(params['name'])
    error = "Something went wrong. Cannot create a subject."
  else
    session[:info] = "Subject with name: #{params['name']} has been successfully created."
  end
  session[:error] = error unless error.nil?

  redirect "/courses-manage"
end

delete "/courses-manage/subject" do
  @logged_user = User.first(id: session[:id])
  @subject = Subject.first(id: params['subject'])

  if @logged_user.nil?
    session[:error] = "You must be logged in to access this site."
    redirect "/login"
  elsif !@logged_user.permission?("courses.manage.access")
    session[:error] = "Access denied. You don't have enough permissions to access this site."
    redirect "/"
  elsif !@logged_user.permission?("subjects.delete")
    error = "You don't have enough permissions to delete a subject."
  elsif @subject.nil?
    error = "It seems that selected subject does not exist."
  else
    @subject.delete
    session[:info] = "Subject has been successfully deleted."
  end
  session[:error] = error unless error.nil?

  redirect "/courses-manage"
end

put "/courses-manage/subject" do
  @logged_user = User.first(id: session[:id])
  @subject = Subject.first(id: params['subject'])
  other_subject = Subject.first(name: params['name'])

  if @logged_user.nil?
    session[:error] = "You must be logged in to access this site."
    redirect "/login"
  elsif !@logged_user.permission?("courses.manage.access")
    session[:error] = "Access denied. You don't have enough permissions to access this site."
    redirect "/"
  elsif !@logged_user.permission?("subjects.edit")
    error = "You don't have enough permissions to edit a subject."
  elsif @subject.nil?
    error = "You must select a subject you want to edit."
  elsif !other_subject.nil?
    error = "Subject with provided name already exist."
  elsif Validation.str_has_special_chars?(params['name'])
    error = "You cannot put any special characters in subject name."
  elsif !@subject.change_name(params['name'])
    error = "Something went wrong. Cannot edit selected course."
  else
    session[:info] = "Subject has been successfully edited."
  end
  session[:error] = error unless error.nil?

  redirect "/courses-manage"
end

post "/courses-manage/tags-category" do
  @logged_user = User.first(id: session[:id])
  params['name'] = params['name']&.strip
  tag_category = TagCategory.fetch(params['name'])

  if @logged_user.nil?
    session[:error] = "You must be logged in to access this site."
    redirect "/login"
  elsif !@logged_user.permission?("courses.manage.access")
    session[:error] = "Access denied. You don't have enough permissions to access this site."
    redirect "/"
  elsif !@logged_user.permission?("tags.category.create")
    error = "You don't have enough permissions to create a tag category."
  elsif !tag_category.nil?
    error = "Tag category with provided name already exist."
  elsif Validation.str_has_special_chars?(params['name'])
    error = "You cannot put any special characters in tag category name."
  elsif !TagCategory.create(params['name'])
    error = "Something went wrong. Cannot create a tag category."
  else
    session[:info] = "Tag category with name: #{params['name']} has been successfully created."
  end
  session[:error] = error unless error.nil?

  redirect "/courses-manage"
end

delete "/courses-manage/tags-category" do
  @logged_user = User.first(id: session[:id])
  tag_category = TagCategory.fetch(params['tags-category'])

  if @logged_user.nil?
    session[:error] = "You must be logged in to access this site."
    redirect "/login"
  elsif !@logged_user.permission?("courses.manage.access")
    session[:error] = "Access denied. You don't have enough permissions to access this site."
    redirect "/"
  elsif !@logged_user.permission?("tags.category.delete")
    error = "You don't have enough permissions to delete a tag category."
  elsif tag_category.nil?
    error = "It seems that selected tag category does not exist."
  elsif !tag_category.delete
    error = "Something went wrong. Cannot delete selected tag category."
  else
    session[:info] = "Tag category has been successfully deleted."
  end
  session[:error] = error unless error.nil?

  redirect "/courses-manage"
end

put "/courses-manage/tags-category" do
  @logged_user = User.first(id: session[:id])
  tag_category = TagCategory.fetch(params['tags-category'])
  params['name'] = params['name']&.strip
  other_tag_category = TagCategory.fetch(params['name'])

  if @logged_user.nil?
    session[:error] = "You must be logged in to access this site."
    redirect "/login"
  elsif !@logged_user.permission?("courses.manage.access")
    session[:error] = "Access denied. You don't have enough permissions to access this site."
    redirect "/"
  elsif !@logged_user.permission?("tags.category.edit")
    error = "You don't have enough permissions to edit a tag category."
  elsif tag_category.nil?
    error = "You must select a tag category you want to edit."
  elsif !other_tag_category.nil?
    error = "Tag category with provided name already exist."
  elsif Validation.str_has_special_chars?(params['name'])
    error = "You cannot put any special characters in tag category name."
  elsif !tag_category.change_name(params['name'])
    error = "Something went wrong. Cannot edit selected tag category."
  else
    session[:info] = "Tag category with name: #{params['name']} has been successfully edited."
  end
  session[:error] = error unless error.nil?

  redirect "/courses-manage"
end

post "/courses-manage/:tag" do
  @logged_user = User.first(id: session[:id])
  params['name'] = params['name']&.strip
  params['type'] = params['tag'][4..] if params['tag'].start_with?("tag-")
  tag = CourseTag.first(type: params['type'], name: params['name'])
  tag_category = TagCategory.fetch(params['type'])

  if @logged_user.nil?
    session[:error] = "You must be logged in to access this site."
    redirect "/login"
  elsif !@logged_user.permission?("courses.manage.access")
    session[:error] = "Access denied. You don't have enough permissions to access this site."
    redirect "/"
  elsif !@logged_user.permission?("tags.create")
    error = "You don't have enough permissions to create a tag."
  elsif !tag.nil?
    error = "#{params['type'].capitalize} tag with provided name already exist."
  elsif tag_category.nil?
    error = "It seems that tag category you're trying to add tag to does not exist."
  elsif Validation.str_has_special_chars?(params['name'])
    error = "You cannot put any special characters in tag name."
  elsif !CourseTag.create(params['type'], params['name'])
    error = "Something went wrong. Cannot create a tag."
  else
    session[:info] = "#{params['type'].capitalize} tag with name: #{params['name']} has been successfully created."
  end
  session[:error] = error unless error.nil?

  redirect "/courses-manage"
end

delete "/courses-manage/:tag" do
  @logged_user = User.first(id: session[:id])
  params['id'] = params[params['tag']]
  params['type'] = params['tag'][4..] if params['tag'].start_with?("tag-")
  tag = CourseTag.first(id: params['id'], type: params['type'])

  if @logged_user.nil?
    session[:error] = "You must be logged in to access this site."
    redirect "/login"
  elsif !@logged_user.permission?("courses.manage.access")
    session[:error] = "Access denied. You don't have enough permissions to access this site."
    redirect "/"
  elsif !@logged_user.permission?("tags.delete")
    error = "You don't have enough permissions to delete tags."
  elsif tag.nil?
    error = "It seems that selected #{params['type']} does not exist."
  elsif !tag.delete
    error = "Something went wrong. Cannot delete selected tag."
  else
    session[:info] = "Selected #{params['type']} tag has been successfully deleted."
  end
  session[:error] = error unless error.nil?

  redirect "/courses-manage"
end

put "/courses-manage/:tag" do
  @logged_user = User.first(id: session[:id])
  params['id'] = params[params['tag']]
  params['name'] = params['name']&.strip
  params['type'] = params['tag'][4..] if params['tag'].start_with?("tag-")
  tag = CourseTag.first(id: params['id'], type: params['type'])
  other_tag = CourseTag.first(type: params['type'], name: params['name'])

  if @logged_user.nil?
    session[:error] = "You must be logged in to access this site."
    redirect "/login"
  elsif !@logged_user.permission?("courses.manage.access")
    session[:error] = "Access denied. You don't have enough permissions to access this site."
    redirect "/"
  elsif !@logged_user.permission?("tags.edit")
    error = "You don't have enough permissions to create a tag."
  elsif tag.nil?
    error = "It seems that selected #{params['type']} tag does not exist."
  elsif !other_tag.nil?
    error = "#{params['type'].capitalize} tag with provided name already exists."
  elsif Validation.str_has_special_chars?(params['name'])
    error = "You cannot put any special characters in tag name."
  elsif !tag.change_name(params['name'])
    error = "Something went wrong. Cannot edit selected #{params['type']} tag."
  else
    session[:info] = "#{params['type'].capitalize} tag has been successfully edited."
  end
  session[:error] = error unless error.nil?

  redirect "/courses-manage"
end
