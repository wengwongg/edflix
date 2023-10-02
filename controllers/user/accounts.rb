get "/account-details" do
  current_user_id = session[:id]
  @logged_user = User.first(id: current_user_id)

  if @logged_user.nil?
    session[:error] = "You must be logged in to access this site."
    redirect "/login"
  end

  @title = "My account"
  erb :'pages/user/account_details', layout: :'templates/layout'
end

post "/account-details" do
  current_user_id = session[:id]
  user = User.first(id: current_user_id)
  if user.nil?
    session[:error] = "You must be logged in to access this site."
    redirect "/login"
  end

  @email = params["email_change"]
  @email_conf = params["email_change_confirmation"]

  @email_form_submitted = !(@email.nil? && @email_conf.nil?)

  @password = params["password_change"]
  @password_conf = params["password_change_confirmation"]

  @password_form_submitted = !(@password.nil? && @password_conf.nil?)

  # initialise variables
  @email_error = nil
  @password_error = nil
  @email_success = nil
  @password_success = nil

  if @email_form_submitted
    # sanitise email inputs
    @email.strip!
    @email_conf.strip!

    # validation rules for email fields

    # both fields missing
    if (@email == "") && (@email_conf == "")
      @email_error = nil
    # one field missing
    elsif @email != "" && (@email_conf == "")
      @email_error = "Please fill out the 're-enter email' field"
    elsif (@email == "") && @email_conf != ""
      @email_error = "Please fill out the 'change email' field"
    # checking if emails are correct
    elsif @email != @email_conf
      @email_error = "Your email does not match"
    elsif (@email == @email_conf) && @email.match(/[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}/).nil?
      # Basic Regex for email validation, modified from source below.
      # https://www.regular-expressions.info/
      @email_error = "Please enter a valid email address."
    elsif user.existing_email(@email)
      @email_error = "Email already exists, please try another email."
    elsif @email == @email_conf
      user.change_email(@email)
      user.save_changes
      @email_success = "Email has been changed successfully"
    end
  end

  if @password_form_submitted
    # don't sanitise password as inputs are strict

    # validation rules for password fields

    # both fields missing
    if (@password == "") && (@password_conf == "")
      @password_error = nil
    # one field missing
    elsif @password != "" && (@password_conf == "")
      @password_error = "Please fill out the 're-enter password' field"
    elsif (@password == "") && @password_conf != ""
      @password_error = "Please fill out the 'change password' field"
    # checking if emails are correct
    elsif @password != @password_conf
      @password_error = "Your password does not match"
    # password matches but not strong enough.
    elsif (@password == @password_conf) && @password.match(/^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$/).nil?
      # Regex matches for a password of 8 characters, minimum one upper, lower case letter, special character and number
      # https://stackoverflow.com/questions/19605150/regex-for-password-must-contain-at-least-eight-characters-at-least-one-number-a
      @password_error = "Password is not strong enough: password of 8 characters,
      minimum one upper, lower case letter, special character and number"
    elsif @password == @password_conf
      user.change_password(@password)
      user.save_changes
      @password_success = "Password has been changed successfully"
    end
  end

  # Check if user decided to delete their account.
  if params[:form_type] == "delete-account-form"
    user.is_deleted = 1
    user.save_changes
    redirect "/logout"
  end

  @title = "My account"
  # loads the same page.
  erb :'pages/user/account_details', layout: :'templates/layout'
end
