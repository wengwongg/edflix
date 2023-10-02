get "/register" do
  @title = "Register page"

  erb :'pages/other/register', layout: :'templates/layout'
end

post "/register" do
  @title = "Register page"

  email = params["email"]
  password = params["password"]
  confirm_password = params["confirm_password"]

  form_submitted = !email.nil? || (!password.nil? && !confirm_password.nil?)

  @email_error = nil
  @password_error = nil

  if form_submitted
    email.strip!
    password.strip!
    confirm_password.strip!

    @email_error = "Email needs to be entered" if email.empty?
    if password.empty?
      @password_error = "Password needs to be entered"
    elsif password != confirm_password
      @password_error = "Passwords do not match"

    elsif password.match(/^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$/).nil?
      # Regex matches for a password of 8 characters, minimum one upper, lower case letter, special character and number
      # https://stackoverflow.com/questions/19605150/regex-for-password-must-contain-at-least-eight-characters-at-least-one-number-a
      @password_error = "Password is not strong enough: password of 8 characters,
			minimum one upper, lower case letter, special character and number"
    end

    if @email_error.nil? && @password_error.nil?
      new_user = User.new
      can_register = new_user.register(email, password)
      # If the user can be registed and does not exist
      if !can_register
        @email_error = "Email already exists, please log in"
      elsif new_user.save_changes
        # create new corresponding user_info record.
        User_info.create_user_info(nil, nil, nil, nil, new_user.id)
        redirect "/login?register_success=true"
      end
    end
  end
  erb :'pages/other/register', layout: :'templates/layout'
end
