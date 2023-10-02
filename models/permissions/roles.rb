class Role < Sequel::Model
  dataset_module do
    def get_roles_from_ids_array(roles)
      raise("Unknown roles. User must have at least one role.") unless roles.is_a?(Array)

      where(id: roles).all
    end
  end
end
