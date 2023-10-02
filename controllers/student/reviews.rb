post "/courses/:id/review" do
  @logged_user = User.first(id: session[:id])
  @course = Course.first(id: params['id'])

  if @course.nil?
    session[:error] = "Course of id #{params['id']} does not exist."
    redirect "/courses"
  elsif @logged_user.nil?
    error = "You must be logged in to add a review."
  elsif !@logged_user.permission?("reviews.add")
    error = "You don't have enough permissions to add reviews."
  elsif params['review_content'].nil? || params['review_content'].strip.eql?("")
    error = "You must provide content of your review."
  elsif params['review_stars'].nil? || params['review_stars'].strip.eql?("") ||
        !Validation.str_is_integer?(params['review_stars'])
    error = "You provided invalid rating."
  elsif Review.add(session[:id], params['id'], params['review_stars'], params['review_content'])
    session[:info] = "Your review has been saved."
  else
    error = "Something went wrong. Cannot save your review..."
  end
  session[:error] = error unless error.nil?

  redirect "/courses/#{params['id']}"
end

delete "/courses/:id/review" do
  @logged_user = User.first(id: session[:id])

  @user_review = Review.first(user_id: session[:id], course_id: params['id'])

  if @logged_user.nil?
    error = "You must be logged in to delete a review."
  elsif !@logged_user.permission?("reviews.delete")
    error = "You don't have enough permissions to delete your reviews."
  elsif @user_review.nil?
    error = "You cannot delete your review if it does not exist."
  else
    @user_review.delete
    session[:info] = "Your review has been deleted."
  end
  session[:error] = error unless error.nil?

  redirect "/courses/#{params['id']}"
end
