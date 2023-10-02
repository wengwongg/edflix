class Provider < Sequel::Model
  dataset_module do
    def get_providers_from_ids_array(providers)
      raise("Provided providers array is actually not an array!") unless providers.is_a?(Array)

      where(id: providers).all
    end
  end

  def self.create(name)
    return false if name.nil? || name.empty? || !Provider.first(name: name).nil? || 
                    Validation.str_has_special_chars?(name)

    Provider.new(name: name).save_changes
    true
  end

  def change_name(name)
    return false if name.nil? || name.empty? || Validation.str_has_special_chars?(name) || 
                    !Provider.first(name: name).nil?

    set(name: name).save_changes
    true
  end

  def delete
    delete_provider_from_users
    delete_provider_from_courses
    super
  end

  def delete_provider_from_courses
    courses = Course.where(provider: id).all
    courses.each do |course|
      course.provider = nil
      course.save_changes
    end
  end

  def delete_provider_from_users
    all_providers = User.exclude(provider_ids: nil).all
    all_providers.each do |provider|
      ids = provider.provider_ids.split(";")
      ids.delete(id.to_s)
      provider.provider_ids = ids.join(";")
      provider.save_changes
    end
  end

  def get_name
    name.to_s
  end
end
