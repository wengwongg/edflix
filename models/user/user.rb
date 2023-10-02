require 'bcrypt'
require_relative 'user_bg_info'

class User < Sequel::Model
  def name
    email
  end

  def fetch_permissions
    @roles = UserRole.get_user_roles(self)
    @policies = UserRole.get_user_policies(@roles)
    @permissions = UserRole.get_user_permissions(@policies)
  end

  def assign_providers(providers_ids)
    user_providers = []
    providers_ids&.each { |provider_id| user_providers.push(provider_id) unless Provider.first(id: provider_id).nil? }
    self.provider_ids = if user_providers.empty?
                          nil
                        else
                          user_providers.join(";")
                        end
  end

  def providers
    return nil if provider_ids.nil?

    begin
      Provider.get_providers_from_ids_array(provider_ids.split(";"))
    rescue RuntimeError
      nil
    end
  end

  def user_roles
    @roles
  end

  def user_permissions
    @permissions
  end

  def permission?(permission)
    UserRole.has_user_permission?(self, permission)
  end

  def role?(role_name)
    fetch_permissions if @roles.nil?

    return false if @roles.nil? || role_name.nil?

    @roles.map(&:name).include?(role_name)
  end

  def student?
    role?("student")
  end

  def admin?
    role?("administrator")
  end

  def role_provider?
    role?("provider")
  end

  def manager?
    role?("manager")
  end

  def moderator?
    fetch_permissions if @roles.nil?

    return false if @roles.nil?

    @roles.map(&:name).include?("moderator")
  end

  def provider?(provider_id)
    return false if providers.nil? || provider_id.nil?

    providers.map(&:id).include?(provider_id)
  end

  def hash_password(incoming_password)
    # We use BCrypt in order to hash passwords.
    # We use it every time user try to log in, change details or register
    BCrypt::Password.create(incoming_password)
  end

  def register(email, incoming_password)
    find_user = User.first(email: email)
    errors.add("email address", "already taken") unless find_user.nil?

    return false unless errors.empty?

    self.email = email
    self.is_verified = false
    # We will hash the password and attempt to dehash based on incoming
    self.password = hash_password(incoming_password)
    true
  end

  def login(email, incoming_password)
    # We try to get user of given email, if it doesn't exist, just add error and return
    find_user = User.first(email: email)
    errors.add("user", "does not exist") if find_user.nil?

    return [false, nil] unless errors.empty?

    # If the user exists then check if the password hashes match and eventually return true and user_id
    my_password = BCrypt::Password.new(find_user.password)
    return [false, nil] unless my_password == incoming_password

    return [true, nil] if find_user.is_deleted.eql?(1)

    return [true, nil] if find_user.is_suspended.eql?(1)

    [true, find_user.id]
  end

  def change_email(updated_email)
    update(email: updated_email)
  end

  def change_password(updated_password)
    new_hashed_password = hash_password(updated_password)
    update(password: new_hashed_password)
  end

  def existing_email(email)
    find_user = User.first(email: email)
    if find_user.nil?
      false
    else
      true
    end
  end

  def get_user_info(user_id)
    user_info = User_info.first(user_id: user_id)
    if user_info.nil?
      %w[null null null null]
    else
      first_name = user_info.first_name
      last_name = user_info.last_name
      subject = user_info.subject
      year_of_study = user_info.year_of_study

      # at least display null on the page if there is no value for it.
      first_name = "null" if first_name.nil?
      last_name = "null" if last_name.nil?
      subject = "null" if subject.nil?
      year_of_study = "null" if year_of_study.nil?

      [first_name, last_name, subject, year_of_study]
    end
  end
end
