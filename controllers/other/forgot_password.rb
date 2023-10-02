enable :sessions
require 'securerandom'

get "/forgot-password" do
  session_userid = session[:id]

  redirect "/" unless session_userid.nil?
  @title = "Forgot password"
  erb :'pages/other/forgot_password', layout: :'templates/layout'
end

post "/forgot-password" do
  # If logged in then redirect to main dashboard page

  @email = params["email"]
  @form_submitted = !@email.nil?

  if @form_submitted
    @email.strip!
    @email_error = "Email needs to be entered" if @email.empty?

    if @email.empty?
      @email_error = "Email needs to be filled"
    else
      # Find the user

      find_user_result = find_user_from_email(@email)
      if find_user_result
        # Setup the new password
        new_pass = SecureRandom.hex(13)
        new_reset = PasswordReset.new
        new_reset.new_password = new_pass

        # Get their ID
        new_reset.user_id = find_user_result.id
        # Reset the user's password
        find_user_result.change_password(new_pass)

        # Create a link using hex
        new_link = SecureRandom.hex(10)
        new_reset.link = new_link
        # At this stage since we can't actually use an email service we compromise on security just to "show" the client
        # CHANGE THIS ONCE EMAILING SERVICE STARTS
        @link_string = "?link=#{new_pass}"
      else
        # We don't want the user knowing that the user does not exist. This is for security purposes
        @success_msg = "An email will have been sent if the email is registered with us."
      end
    end
  end

  @title = "Forgot password"
  erb :'pages/other/forgot_password', layout: :'templates/layout'
end
