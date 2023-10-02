get "/login" do
  session_userid = session[:id]

  redirect "/" unless session_userid.nil?

  @title = "Login"
  erb :'pages/other/login', layout: :'templates/layout'
end

post "/login" do
  # If logged in then redirect to main dashboard page
  # s$*A6CDU7Xurp2

  @email = params["email"]
  @password = params["password"]

  @form_submitted = !@email.nil? || !@password.nil?

  @email_error = nil
  @password_error = nil

  if @form_submitted
    @email.strip!
    @password.strip!

    @email_error = "Email needs to be entered" if @email.empty?
    @password_error = "Password needs to be entered" if @password.empty?

    if !@email.empty? && !@password.empty?
      new_user = User.new
      login_data = new_user.login(@email, @password)
      if login_data[0]
        if login_data[1].nil?
          session[:error] = "You cannot log in. Your account has been suspended or deleted."
          redirect "/login"
        end
        session[:suggest_counter] = 0
        session[:id] = login_data[1]
        redirect "/"
      else
        @password_error = "Email or password is incorrect"
      end
    end
  end

  @title = "Login"
  erb :'pages/other/login', layout: :'templates/layout'
end
