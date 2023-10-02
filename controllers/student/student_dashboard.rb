get "/student-dashboard" do
  @logged_user = User.first(id: session[:id])

  if @logged_user.nil?
    error = "You must be logged in to see student dashboard."
  elsif !@logged_user.student?
    error = "You must be a student in order to see student dashboard."
  end

  unless error.nil?
    session[:error] = error
    redirect "/"
  end

  @suggested_courses = SuggestedCourses.get(@logged_user.id, 5)
  @user_info = User_info.first(user_id: @logged_user.id)
  @student_subject = Subject.first(id: @user_info&.subject)
  @student_courses = StudentCourse.filtered_student_courses(@logged_user.id, nil)
  @student_stats = StudentStats.all_sorted_stats(@logged_user.id)
  @current_tag = CourseTag.first(id: params['pathway_tag'])

  @title = "Student dashboard"
  erb :'pages/student/student_dashboard', layout: :'templates/layout'
end
