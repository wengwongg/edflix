get "/mycourses" do
  # Fields needed for filtering to work
  @current_subject = Subject.first(id: params['subject'].to_i)
  @course_statuses = { 1 => "Enrolled", 2 => "Paused", 3 => "Completed" }

  @logged_user = User.first(id: session[:id])

  if @logged_user.nil?
    error = "You must be logged in to see courses dashboard."
  elsif !@logged_user.student?
    error = "You must be a student in order to see courses dashboard."
  end

  unless error.nil?
    session[:error] = error
    redirect "/"
  end

  pagination_and_student_courses = StudentCourse.create_student_courses_hash(session[:id], params)
  @student_courses_hash = pagination_and_student_courses[0]
  @pagination = pagination_and_student_courses[1]
  @title = "My courses"
  @enabled_filters = { course_name: true, subject: true, pause_date: true, enroll_date: true,
                       finish_date: true, course_status: true }
  erb :'pages/student/courses_dashboard', layout: :'templates/layout'
end


get "/courses/:id/enroll" do
  @course = Course.first(id: params['id'])
  @logged_user = User.first(id: session[:id])
  @student_course = StudentCourse.first(user_id: session[:id], course_id: params['id'])

  if @course.nil? || @logged_user.nil?
    error = "You must be logged in to enroll to a course."
  elsif !@course.nil? && !@course.public? && !CourseViewer.can_view_course?(@logged_user.id, @course.id)
    error = "You cannot enroll to this course. This course is private."
  elsif !@course.nil? && @course.is_archived.eql?(1)
    error = "You cannot enroll to this course. This course is archived."
  elsif !@logged_user.student?
    error = "You must be a student in order to enroll to a course."
  elsif !@student_course.nil? && (@student_course.status.eql?(1) || @student_course.status.eql?(2))
    error = "You are already enrolled to this course."
  elsif StudentCourse.enroll(session[:id], params['id'].to_i)
    session[:info] = "You are now enrolled to course #{@course.name}."
  else
    error = "Something went wrong. Cannot enroll to a course."
  end
  session[:error] = error unless error.nil?

  redirect "/courses/#{params['id']}"
end

get "/courses/:id/pause" do
  @course = Course.first(id: params['id'])
  @logged_user = User.first(id: session[:id])
  @student_course = StudentCourse.first(user_id: session[:id], course_id: params['id'])

  if @course.nil? || @logged_user.nil?
    error = "You must be logged in to pause a course."
  elsif !@logged_user.student?
    error = "You must be a student in order to pause a course."
  elsif @student_course.nil?
    error = "You cannot pause a course you are not enrolled to."
  elsif !@student_course.nil?
    case @student_course.status
    when 2
      error = "You have already paused this course."
    when 3
      error = "You cannot pause finished course."
    else
      if @student_course.pause
        session[:info] = "You have successfully paused course #{@course.name}."
      else
        error = "Something went wrong. Cannot pause a course."
      end
    end
  end
  session[:error] = error unless error.nil?

  redirect "/courses/#{params['id']}"
end

get "/courses/:id/resume" do
  @course = Course.first(id: params['id'])
  @logged_user = User.first(id: session[:id])
  @student_course = StudentCourse.first(user_id: session[:id], course_id: params['id'])

  if @course.nil? || @logged_user.nil?
    error = "You must be logged in to resume a course."
  elsif !@logged_user.student?
    error = "You must be a student in order to resume a course."
  elsif @student_course.nil?
    error = "You cannot resume a course you are not enrolled to."
  elsif !@student_course.nil?
    case @student_course.status
    when 1
      error = "You cannot resume course which is not paused."
    when 3
      error = "You cannot resume completed course."
    else
      if @student_course.resume
        session[:info] = "You have successfully resumed course #{@course.name}."
      else
        error = "Something went wrong. Cannot resume a course."
      end
    end
  end
  session[:error] = error unless error.nil?

  redirect "/courses/#{params['id']}"
end

get "/courses/:id/cancel" do
  @course = Course.first(id: params['id'])
  @logged_user = User.first(id: session[:id])
  @student_course = StudentCourse.first(user_id: session[:id], course_id: params['id'])

  if @course.nil? || @logged_user.nil?
    error = "You must be logged in to cancel a course."
  elsif !@logged_user.student?
    error = "You must be a student in order to cancel a course."
  elsif @student_course.nil?
    error = "You cannot cancel a course you are not enrolled to."
  elsif !@student_course.nil?
    if @student_course.status.eql?(3)
      error = "You cannot cancel completed course."
    elsif @student_course.cancel
      session[:info] = "You have successfully cancelled course #{@course.name}."
    else
      error = "Something went wrong. Cannot cancel a course."
    end
  end
  session[:error] = error unless error.nil?

  redirect "/courses/#{params['id']}"
end

get "/courses/:id/finish" do
  @course = Course.first(id: params['id'])
  @logged_user = User.first(id: session[:id])
  @student_course = StudentCourse.first(user_id: session[:id], course_id: params['id'])

  if @course.nil? || @logged_user.nil?
    error = "You must be logged in to finish a course."
  elsif !@logged_user.student?
    error = "You must be a student in order to finish a course."
  elsif @student_course.nil?
    error = "You cannot finish a course you are not enrolled to."
  else
    if @student_course.status.eql?(3)
      error = "You have already completed this course."
    else
      if @student_course.finish
        session[:info] = "You have successfully completed course #{@course.name}."
      else
        error = "Something went wrong. Cannot finish a course."
      end
    end
  end
  session[:error] = error unless error.nil?

  redirect "/courses/#{params['id']}"
end
