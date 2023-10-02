class CourseTag < Sequel::Model(:course_tags)
  def change_name(tag_name)
    return false unless CourseTag.name_valid?(tag_name)

    all_type_tags = CourseTag.where(type: type).all
    return false if all_type_tags.map(&:name).include?(tag_name)

    set(name: tag_name).save_changes
    true
  end

  def delete
    begin
      courses = Filtering.impose_tag_filters(Course.all, [id.to_s])
      courses.each do |course|
        course_tags = course.tags.split(";")
        course_tags.delete(id.to_s)
        course.tags = course_tags.join(";")
        course.save_changes
      end
      super
    rescue StandardError
      return false
    end
    true
  end

  def self.create(type, tag_name)
    return false unless could_create?(type, tag_name)

    all_type_tags = where(type: type).all
    if all_type_tags.length.eql?(1) && all_type_tags.fetch(0).name.nil?
      empty_tag = all_type_tags.fetch(0)
      empty_tag.set(name: tag_name).save_changes
    else
      CourseTag.new(type: type, name: tag_name).save_changes
    end
    true
  end

  def self.could_create?(type, tag_name)
    return false if !name_valid?(tag_name) || type.nil?

    all_tags = all
    return false unless all_tags.map(&:type).include?(type)

    type_tags = where(type: type).all
    return false if type_tags.map(&:name).include?(tag_name)

    true
  end

  def self.name_valid?(tag_name)
    !tag_name.nil? && tag_name.is_a?(String) && !tag_name.empty? && !Validation.str_has_special_chars?(tag_name)
  end

  def self.all_tags_hash
    all_tags = all
    new_hash = {}

    all_tags.each do |tag|
      new_hash[tag.type] = [] unless new_hash.include?(tag.type)
      current_type_array = new_hash.fetch(tag.type)
      current_type_array.push(tag)
      new_hash[tag.type] = current_type_array
    end

    new_hash
  end

  def self.extract_tags_from_params(params)
    return nil if params.nil?

    extracted_tags = []
    params.each do |key, value|
      next unless key.start_with?("course_tag")

      extracted_tags.push(value) if Validation.str_is_integer?(value)
      extracted_tags.push(*value.select { |val| Validation.str_is_integer?(val) }) if value.is_a?(Array)
    end
    return nil if extracted_tags.empty?

    extracted_tags
  end

  def self.provided_tags_exist?(tags_string)
    return true if tags_string.nil?

    all_tags = all.map(&:id)
    tags_string.split(";").all? { |tag| all_tags.include?(tag.to_i) }
  end
end
