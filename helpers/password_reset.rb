# This helper class provides a way to structure a password reset for a user.
# It will have to be reworked once emailing comes out.
class PasswordReset
  attr_accessor :user_id, :link, :new_password, :expiry

  # Set an expiry of 10 minutes
  @expiry = Time.new + 600

  def self.compare_link(incoming_link)
    return true if incoming_link == link

    false
  end

  def check_expiry
    return true if Time.new < expiry

    false
  end
end
