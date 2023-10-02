# CHANGE THIS ONCE EMAILING SERVICE STARTS
get "/reset-password" do
  @reset_pass = params["link"]
  # This obviously is not secure and has to be changed
  if @reset_pass.nil? || @reset_pass.empty?
    @hash_error = "This hash is empty and not valid"
  else
    @success_msg = "Your new password is #{@reset_pass}"
  end

  @title = "Reset password"
  erb :'pages/other/reset_password', layout: :'templates/layout'
end
