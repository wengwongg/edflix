def find_user_from_email(email)
  find_user = User.first(email: email)
  puts(find_user)
  return find_user unless find_user.nil?

  false
end
