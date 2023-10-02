get "/courses" do
  # Fields needed for filtering to work
  @logged_user = User.first(id: session[:id])
  request_params = params
  request_params['hide_private'] = true if @logged_user.nil? || !@logged_user.permission?("courses.private.view")
  request_params['viewer_courses'] = CourseViewer.fetch_user_courses(@logged_user.id).map(&:course_id) if @logged_user
  request_params['providers'] = @logged_user.provider_ids.split(";") if @logged_user && !@logged_user.provider_ids.nil?

  # Filtering if any filter enabled
  filtered_courses = Filtering.courses(request_params, nil)
  filtered_courses_with_tags = Filtering.impose_tag_filters(filtered_courses,
                                                            CourseTag.extract_tags_from_params(request_params))
  @pagination = PaginatedArray.new(filtered_courses_with_tags, request_params)
  @courses = @pagination.paginated_array

  # We set title of current page
  @title = "All courses"
  @enabled_filters = { course_name: true, subject: true, lecturer: true, start_date: true, end_date: true,
                       course_tag: true, providers: true }
  erb :'pages/user/courses_list', layout: :'templates/layout'
end

get "/report" do
  # Verify permissions to view the page.
  @logged_user = User.first(id: session[:id])

  if @logged_user.nil?
    session[:error] = "You must be logged in to access this site."
    redirect "/login"
  elsif !@logged_user.permission?("reports.manage.access")
    session[:error] = "Access denied. You don't have enough permissions to access this site."
    redirect "/"
  end

  @title = "Reports"
  @course_search = params.fetch("course_search", "")
  @subjects = Subject.all

  @courses = if @course_search.empty?
               Course.all
             else
               Course.where(Sequel.like(:name, "%#{@course_search}%"))
             end

  @users = User.all
  @providers = Provider.all
  @userinfo = User_info.all
  @students = User.where(roles_ids: 1)
  @student1styear = User_info.where(year_of_study: 1)
  @student2ndyear = User_info.where(year_of_study: 2)
  @student3rdyear = User_info.where(year_of_study: 3)
  # @studentNthyear = User_infos.where(Sequel.where(:year_of_study >3))

  erb :'pages/other/report_page', layout: :'templates/layout'
end
