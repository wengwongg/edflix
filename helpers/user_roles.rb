class UserRole
  def self.get_user_roles(user)
    return nil if user.nil?

    # Splitting user roles_ids into array
    user_roles_ids = user.roles_ids&.split(';', -1)
    # Getting all roles which include ids from user_roles_ids array
    user_roles = Role.get_roles_from_ids_array(user_roles_ids)
    return nil if user_roles.empty?

    user_roles
  end

  def self.get_user_policies(user_roles)
    return nil if user_roles.nil? || !user_roles.is_a?(Array)

    all_policies = []
    user_roles.each do |user_role|
      current_policies = if user_role.policies.nil?
                           []
                         else
                           user_role.policies.split(';')
                         end
      # Add all unrepeated policies to all_policies array
      all_policies = all_policies.union(current_policies)
    end
    return nil if all_policies.empty?

    # Finally get all policies from ids array (similar as in the get_user_roles method)
    Policy.get_policies_from_ids_array(all_policies.uniq)
  end

  def self.get_user_permissions(user_policies)
    return nil if user_policies.nil? || !user_policies.is_a?(Array)

    all_permissions = Set.new
    user_policies.each do |user_policy|
      user_policy.permissions&.split(";")&.each do |permission|
        all_permissions.add(permission)
      end
    end
    return nil if all_permissions.empty?

    all_permissions
  end

  def self.has_user_permission?(user, permission)
    return false if user.nil?

    user.fetch_permissions if user.user_roles.nil?
    return false if user.user_permissions.nil? || !user.user_permissions.is_a?(Set)

    user.user_permissions.include?(permission)
  end
end
