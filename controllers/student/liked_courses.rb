post "/courses/:id/like" do
  @course_id = params["id"].to_i
  @logged_user = User.first(id: session[:id])

  redirect "/login" if @logged_user.nil?

  liked_course = Liked_course.new
  liked_course.add_liked_course(@logged_user[:id], @course_id)
  liked_course.save_changes
  redirect "/courses/#{@course_id}"
end

post "/courses/:id/dislike" do
  @course_id = params["id"].to_i
  @logged_user = User.first(id: session[:id])

  liked_course_entry = Liked_course.first(user_id: @logged_user.id, course_id: @course_id)
  liked_course_entry&.delete
  redirect "/courses/#{@course_id}"
end

get "/liked-courses" do
  @logged_user = User.first(id: session[:id])

  @liked_course_id_list = Liked_course.get_all_liked_courses(@logged_user&.id).map(&:course_id)
  @liked_course_list = []
  @liked_course_id_list.each do |course_id|
    @liked_course_list.append(Course.first(id: course_id))
  end
  @pagination = PaginatedArray.new(@liked_course_list, params)
  @title = "Liked courses"
  erb :'pages/student/liked_courses', layout: :'templates/layout'
end
