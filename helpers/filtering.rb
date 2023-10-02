class Filtering
  def self.courses(params, courses_ids)
    return Course.filter_results(params, courses_ids) if any_courses_filters_imposed?(params)

    Course.default_order.all
  end

  def self.student_courses(filtered_courses, student_courses)
    return [] if filtered_courses.nil? || student_courses.nil? ||
                 !filtered_courses.is_a?(Array) || !student_courses.is_a?(Array) ||
                 filtered_courses.empty? || student_courses.empty?

    courses_ids = filtered_courses.map(&:id)
    student_courses.select { |student_course| courses_ids.include?(student_course.course_id) }
  end

  def self.any_courses_filters_imposed?(params)
    params = {} if params.nil?
    current_subject = Subject.first(id: params['subject'])

    !((params['subject'].nil? or current_subject.nil?) &&
      (params['course_name'].nil? or params['course_name'].eql?("")) &&
      (params['lecturer'].nil? or params['lecturer'].eql?("")) &&
      params['provider'].nil? && params['start_date'].nil? && params['hide_private'].nil?)
  end

  def self.impose_tag_filters(filtered_courses, chosen_tags)
    return filtered_courses if chosen_tags.nil?

    return [] if filtered_courses.nil? || !filtered_courses.is_a?(Array) || filtered_courses.empty?

    filtered_courses.select do |course|
      next if course.tags.nil?

      course_tags = course.tags.split(";")
      chosen_tags.all? { |chosen_tag| course_tags.include?(chosen_tag) }
    end
  end
end
