class Liked_course < Sequel::Model
  def add_liked_course(user_id, course_id)
    #  check if course exists
    return unless Liked_course.first(course_id: course_id, user_id: user_id).nil?

    self.user_id = user_id
    self.course_id = course_id
  end

  def self.get_liked_course(user_id, course_id)
    entry = Liked_course.first(user_id: user_id, course_id: course_id)
    return false if entry.nil?

    true
  end

  dataset_module do
    def get_all_liked_courses(user_id)
      return [] if user_id.nil?

      where(user_id: user_id).all
    end
  end
end
