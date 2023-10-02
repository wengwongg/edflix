require 'uri'

get "/suggest-course" do
  # Verify permissions to view the page.
  @logged_user = User.first(id: session[:id])

  if @logged_user.nil?
    session[:error] = "You must be logged in to access this site."
    redirect "/login"
  elsif !@logged_user.permission?("courses.suggest")
    session[:error] = "Access denied. You don't have enough permissions to access this site."
    redirect "/"
  end

  @title = "Suggest course"
  erb :'pages/user/suggest_course', layout: :'templates/layout'
end

post "/suggest-course" do
  # Verify permissions to view the page.
  @logged_user = User.first(id: session[:id])

  if @logged_user.nil?
    session[:error] = "You must be logged in to access this site."
    redirect "/login"
  elsif !@logged_user.permission?("courses.suggest")
    session[:error] = "Access denied. You don't have enough permissions to access this site."
    redirect "/"
  end

  suggest_counter = session[:suggest_counter]

  # can't submit a suggestion more than 3 times.
  if suggest_counter < 3
    @course_name = params["course_name"]
    @course_url = params["course_url"]

    # sanitise user inputs
    @course_name.strip!
    @course_url.strip!

    # initialise error variables
    @course_name_error = nil
    @course_url_error = nil

    # Perform data validation

    # Empty course field
    if @course_name == ""
      @course_name_error = "Course name field cannot be empty."
    else
      # Course already exists.
      courses = Course.all
      courses.each do |course|
        @course_name_error = "Course already exists in our system." if course.name.downcase == @course_name.downcase
      end
    end

    # Invalid URL check
    def valid_url?(url)
      # attempt to return URI object representing the URL
      uri = URI.parse(url)
      uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
    rescue URI::InvalidURIError
      # otherwise catch the exception and return false.
      false
    end

    if @course_url == ""
      @course_url_error = "URL field cannot be empty."
    elsif !valid_url?(@course_url)
      @course_url_error = "Invalid URL entered, must be HTTPS/HTTP"
    end

    # If passes all the validation checks, then store into the database.
    if @course_url_error.nil? && @course_name_error.nil?
      @suggestion_message = "Thank you for your suggestion. We will look into it further."

      new_course_suggestion = User_suggested_course.new(user_id: @logged_user.id, name: @course_name, url: @course_url)
      new_course_suggestion.save_changes

      # clear the fields to avoid resubmission of data.
      @course_url = ""
      @course_name = ""

      # increment the suggestion counter.
      session[:suggest_counter] = session[:suggest_counter] + 1
    end
  else
    @suggestion_message = "You cannot submit more than three submissions during the same session."
  end

  @title = "Suggest course"
  erb :'pages/user/suggest_course', layout: :'templates/layout'
end
