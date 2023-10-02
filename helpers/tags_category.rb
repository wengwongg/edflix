class TagCategory
  def initialize(name)
    @name = name
    @id = name
  end

  def change_name(name)
    all = TagCategory.all
    return false if all.nil? || all.empty? || !TagCategory.validate_name(name)

    CourseTag.where(type: @name).all.each do |tag|
      tag.set(type: name).save_changes
    end
    true
  end

  def delete
    begin
      tags = CourseTag.where(type: @name).all
      tags_ids = tags.map { |tag| tag.id.to_s }
      TagCategory.delete_tags_from_all_courses(tags_ids)

      tags.each(&:delete)
    rescue StandardError
      return false
    end
    true
  end

  # If a tag type/category is deleted, we need to remove all tags associated with this category from courses
  def self.delete_tags_from_all_courses(tags_ids)
    return if tags_ids.nil? || !tags_ids.is_a?(Array) || tags_ids.empty?

    # Iterate through all courses
    Course.all.each do |course|
      # If course does not contain any tags -> go to next iteration
      # In case something unpredictible happens and subject is deleted from the db, it causes all courses
      # containing that subject to have subject set to null. We need to check that too
      next if course.tags.nil? || course.subject.nil?

      # Now split tags by ";" and reject all tags from tags_ids (we want them to be deleted)
      course_tags = course.tags.split(";").reject { |tag| tags_ids.include?(tag) }
      # Finally set the tags back, if the list became empty, we just set it nil
      course.tags = if course_tags.nil? || course_tags.empty?
                      nil
                    else
                      course_tags.join(";")
                    end
      course.save_changes
    end
  end

  def self.create(category_name)
    return false unless validate_name(category_name) && fetch(category_name).nil?

    CourseTag.new(type: category_name).save_changes
    true
  end

  def self.all
    all_tags = CourseTag.all
    return [] if all_tags.empty?

    categories_names = Set.new(all_tags.map(&:type))
    categories_names.to_a.map { |category_name| TagCategory.new(category_name) }
  end

  def self.fetch(category_name)
    return nil unless validate_name(category_name)

    categories = TagCategory.all
    return nil if categories.nil? || categories.empty? || !categories.map(&:name).include?(category_name)

    new(category_name)
  end

  def self.validate_name(str)
    !str.nil? && str.is_a?(String) && !str.empty? &&
      !Validation.str_has_special_chars?(str)
  end

  attr_accessor :id, :name
end
