enable :sessions

get "/user_bg_info" do
  @logged_user = User.first(id: session[:id])
  if @logged_user.nil?
    session[:error] = "You must be logged in to access this site."
    redirect "/login"
  end

  @logged_user.fetch_permissions
  @roles = @logged_user.user_roles

  bg_info = User_info.first(user_id: session[:id])
  @first_name = bg_info&.first_name
  @last_name = bg_info&.last_name
  @year_of_study = bg_info&.year_of_study
  @subject = bg_info&.subject

  @title = "Background information"
  erb :'pages/user/user_bg_info', layout: :'templates/layout'
end

post "/user_bg_info" do
  @logged_user = User.first(id: session[:id])
  if @logged_user.nil?
    session[:error] = "You must be logged in to edit background details."
    redirect "/login"
  end

  @first_name = params["first_name"]&.strip
  @last_name = params["last_name"]&.strip
  @year_of_study = params["year_of_study"]&.to_i
  @subject = params["subject"]&.to_i

  # validation rules
  # only checking if first name and last name are present
  # so as to not make any false assumptions on the format of someone's name
  @first_name_error = "First name needs to be entered" if @first_name&.empty?
  @last_name_error = "Last name needs to be entered" if @last_name&.empty?
  @year_of_study_error = "Please enter a year of study between 1 and 6" if @year_of_study < 1 || @year_of_study > 6
  @subject_error = "Please select a subject from the list" if @subject.nil? || Subject.first(id: @subject).nil?

  if @first_name_error.nil? && @last_name_error.nil? && @year_of_study_error.nil? && @subject_error.nil?
    find_user = User_info.first(user_id: session[:id])
    if find_user.nil?
      # creates new record if user is entering background information for the first tiime
      User_info.create_user_info(@subject, @year_of_study, @first_name, @last_name, session[:id])
    else
      # updates user's background information record if they have previously entered background information
      find_user.user_info_load(@subject, @year_of_study, @first_name, @last_name)
      find_user.save_changes
    end
    session[:info] = "Your background details has been updated."
  end

  @title = "Background information"
  erb :'pages/user/user_bg_info', layout: :'templates/layout'
end
