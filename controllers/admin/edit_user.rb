get "/edit-user" do
  # Verify permissions to view the page.
  @logged_user = User.first(id: session[:id])

  if @logged_user.nil?
    session[:error] = "You must be logged in to access this site."
    redirect "/login"
  elsif !@logged_user.permission?("users.manage.access")
    session[:error] = "Access denied. You don't have enough permissions to access this site."
    redirect "/"
  end

  user_id = params["id"]
  @user = User.first(id: user_id)
  # get a sample subject object to be able to access methods.
  @subject = Subject.first(id: 1)
  @roles = Role.where(staff_role: @user&.is_staff).all
  @subjects = Subject.all
  @title = "Edit user"
  erb :'pages/admin/edit_user', layout: :'templates/layout'
end

post "/edit-user" do
  # Verify permissions to view the page.
  @logged_user = User.first(id: session[:id])

  if @logged_user.nil?
    session[:error] = "You must be logged in to access this site."
    redirect "/login"
  elsif !@logged_user.permission?("users.manage.access")
    session[:error] = "Access denied. You don't have enough permissions to access this site."
    redirect "/"
  end

  user_id = params["id"]
  @user = User.first(id: user_id)
  @subject = Subject.first(id: 1)
  @roles = Role.where(staff_role: @user&.is_staff).all
  @subjects = Subject.all

  @first_name = params["first_name"]
  @last_name = params["last_name"]
  @subject_id = params["subject"]
  @email = params["email"]
  @year_of_study = params["year_of_study"]

  # returns the id value if checked.
  @role1 = params["role1"]
  @role2 = params["role2"]
  @role3 = params["role3"]
  @role4 = params["role4"]
  @role5 = params["role5"]
  roles_inputs = [@role1, @role2, @role3, @role4, @role5]

  @providers_ids = params['provider'] unless @role2.nil?

  # initialise the error variables
  @first_name_error = nil
  @last_name_error = nil
  @email_error = nil
  @roles_error = nil
  @year_of_study_error = nil

  # sanitise all text user inputs
  @first_name.strip!
  @last_name.strip!
  @email.strip!
  @year_of_study.strip!

  # validation rules for potential errors
  @first_name_error = "First name can only contain letters and spaces." if @first_name.match(/^[a-zA-Z\s]*$/).nil?

  @last_name_error = "Last name can only contain letters and spaces." if @last_name.match(/^[a-zA-Z\s]*$/).nil?

  if @email == ""
    @email_error = "Email cannot be left empty."
  elsif @email.match(/[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}/).nil?
    @email_error = "Please enter a valid email address."
  # throw an error if we're actually trying to change the email and it exists already in the db.
  elsif @user.existing_email(@email) && @email != @user.email
    @email_error = "Email already exists, please try another email."
  end

  if @logged_user.admin? && (@logged_user.id == @user.id) && @role4.nil?
    @roles_error = "Administrator cannot get rid of their own administrator role."
  elsif @role1.nil? && @role2.nil? && @role3.nil? && @role4.nil? && @role5.nil?
    @roles_error = "Please set at least one role."
  end

  # year of study doesn't have the NOT NULL constraint, can be empty.
  if !(@year_of_study == "") && (@year_of_study.to_i < 1 || @year_of_study.to_i > 6)
    @year_of_study_error = "Year of study must be between 1 to 6."
  end

  @provider_error = "Provider cannot be empty" if @role2 && @user.role_provider? && @providers_ids.nil?

  # If no errors, pass the values into db.
  if @first_name_error.nil? && @last_name_error.nil? && @email_error.nil? && @roles_error.nil? &&
     @year_of_study_error.nil? && @provider_error.nil?

    # get the user info record that needs to be changed
    user_info = User_info.first(user_id: user_id)

    # if the user doesn't have a user info record, create one.
    if user_info.nil?
      user_info = User_info.new
      user_info.user_id = user_id
    end

    # if first_name and last_name are empty
    user_info.first_name = if @first_name == ""
                             nil
                           else
                             @first_name
                           end

    user_info.last_name = if @last_name == ""
                            nil
                          else
                            @last_name
                          end

    user_info.subject = @subject_id

    # if the year of study is empty.
    user_info.year_of_study = if @year_of_study == ""
                                nil
                              else
                                @year_of_study.to_i
                              end
    user_info.save_changes

    # change the user's record
    @user.email = @email

    roles_list = ""
    roles_inputs_not_nil = []
    roles_inputs.each do |role|
      roles_inputs_not_nil.append(role) unless role.nil?
    end

    for i in 0..(roles_inputs_not_nil.length - 1)
      roles_list = if i == 0
                     roles_inputs_not_nil[0].to_s
                   else
                     roles_list + ";" + roles_inputs_not_nil[i].to_s
                   end
    end

    @user.roles_ids = roles_list
    @user.assign_providers(@providers_ids)

    @user.save_changes

    @success = "Data has been successfully updated."
  end
  @title = "Edit user"
  erb :'pages/admin/edit_user', layout: :'templates/layout'
end
