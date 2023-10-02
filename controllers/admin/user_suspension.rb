post "/user-suspension" do
  user_id = params["id"]
  suspend = params["suspend"]
  unsuspend = params["unsuspend"]

  user = User.first(id: user_id)

  if user.nil?
    session[:error] = "User with provided id does not exist."
  elsif user.id.eql?(session[:id])
    session[:error] = "You cannot suspend yourself..."
  else
    user.is_suspended = 1 if suspend == "1"

    user.is_suspended = 0 if unsuspend == "0"

    user.save_changes
  end

  redirect "/user-list"
end
