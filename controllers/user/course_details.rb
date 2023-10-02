get "/courses/:id" do
  @course = Course.first(id: params['id'].to_i)
  @logged_user = User.first(id: session[:id])
  @student_course = StudentCourse.first(user_id: session[:id], course_id: params['id'].to_i)
  @course_statuses = { 1 => "Enrolled", 2 => "Paused", 3 => "Completed" }
  @course_status = @student_course.status unless @student_course.nil?

  error = nil
  if @course.nil?
    error = "No course for id #{params['id']} was found."
  elsif @course.is_archived.eql?(1) || !@course.public?
    if @logged_user.nil?
      error = "You must be logged in to see this site."
    elsif !(@logged_user.provider?(@course.provider) ||
      @logged_user.permission?("courses.private.view") ||
      StudentCourse.first(user_id: @logged_user.id, course_id: @course.id))
      if @course.is_archived.eql?(1) || !CourseViewer.can_view_course?(@logged_user.id, @course.id)
        error = "You don't have enough permissions to access this site."
      end
    end
  end

  unless error.nil?
    session[:error] = error
    redirect "/courses"
  end

  @liked_course_exists = Liked_course.get_liked_course(session[:id], @course.id)
  @course_subject = Subject.first(id: @course.subject)

  params['page_size'] = nil
  @review = Review.first(user_id: session[:id], course_id: params['id'])
  @pagination = PaginatedArray.new(Review.course_reviews(params['id']), params)
  @disable_pagination_size = true

  @title = "Course details"
  erb :'pages/user/course_details', layout: :'templates/layout'
end
