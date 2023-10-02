get "/user-list" do
  # Verify permissions to view the page.
  @logged_user = User.first(id: session[:id])

  if @logged_user.nil?
    session[:error] = "You must be logged in to access this site."
    redirect "/login"
  elsif !@logged_user.permission?("users.manage.access")
    session[:error] = "Access denied. You don't have enough permissions to access this site."
    redirect "/"
  end

  @users = User.all
  # get a sample subject object to be able to access methods.
  @subject = Subject.first(id: 1)

  # Add filtering function.
  # all these params are nil when just landing normally on the /user-list page.
  email_filter = params["email_filter"]
  subject_filter = params["subject"]
  suspension_filter = params["suspension_filter"]

  # !(.nil?) makes sure that this code doesn't run when just landing normally on the /user-list page.
  # nil.strip! would cause errors.
  # when submitting the form with empty field, it would give "", not nil - considered different objects.
  if !email_filter.nil? && email_filter != ""
    email_filter.strip!
    @users = User.where(email: email_filter).all
  end

  if !subject_filter.nil? && !Subject.first(id: subject_filter).nil?
    user_info_records = User_info.where(subject: subject_filter)
    @users = []
    # add the users with the subject into the array.
    user_info_records.each do |user_info|
      @users.append(User.first(id: user_info.user_id))
    end
  end

  if !suspension_filter.nil? && !suspension_filter.eql?("")
    @users = User.where(is_suspended: suspension_filter.to_i).all
  end

  # Pagination
  @enabled_filters = { user_email: true, subject: true, suspension: true }
  @pagination = PaginatedArray.new(@users, params)
  @users = @pagination.paginated_array
  @title = "Users list"
  erb :'pages/admin/user_list', layout: :'templates/layout'
end
