class CourseViewer < Sequel::Model(:course_viewers)
  dataset_module do
    def fetch_user_courses(user_id)
      return [] if user_id.nil? || User.first(id: user_id).nil?

      where(user_id: user_id).all
    end
  end

  def self.can_view_course?(user_id, course_id)
    return false if user_id.nil? || course_id.nil?

    CourseViewer.where(user_id: user_id, course_id: course_id).all.length.positive?
  end

  # Giving user_ids permission to view private course
  def self.create(user_ids, course_id)
    return unless params_valid?(user_ids, course_id)

    # We select all elements which are valid
    user_ids = user_ids.select { |id| Validation.str_is_integer?(id) }
    delete_unchecked_users(user_ids, course_id)

    # From the user_ids we have left we add new CourseViewer to db (for given user_id and course_id)
    user_ids.each do |user_id|
      next if User.first(id: user_id).nil?

      CourseViewer.new(user_id: user_id.to_i, course_id: course_id).save_changes
    end
  end

  def self.delete_unchecked_users(user_ids, course_id)
    # We take out permissions for users who had permission to view course, but they should not have it now
    current_viewers = CourseViewer.where(course_id: course_id).all
    current_viewers.each do |viewer|
      # If a user has permission to view course, but they're not on the list, just delete viewer
      # Otherwise just remove this user_id from the array and continue to next iteration
      if user_ids.include?(viewer.user_id.to_s)
        user_ids.delete(viewer.user_id.to_s)
      else
        viewer.delete
      end
    end
  end

  def self.params_valid?(user_ids, course_id)
    !(user_ids.nil? || !user_ids.is_a?(Array) || course_id.nil? || Course.first(id: course_id).nil?)
  end

  def self.extract_viewers_from_params(params)
    return nil if params.nil?

    extracted_viewers = []
    params.each do |key, value|
      next unless key.start_with?("course_viewer")

      extracted_viewers.push(*value.select { |val| Validation.str_is_integer?(val) }) if value.is_a?(Array)
    end
    return [] if extracted_viewers.empty?

    extracted_viewers
  end
end
