class SuggestedCourses
  def initialize(user_id, quantity, chosen_tag = nil)
    @student_id = user_id
    fetch_student_stats(chosen_tag)
    fetch_courses_lists
    start_algorithm(quantity)
  end

  def fetch_student_stats(chosen_tag)
    @student_stats = []
    if chosen_tag.nil?
      @student_stats = StudentStats.all_sorted_stats(@student_id)
    elsif !CourseTag.first(id: chosen_tag).nil?
      chosen_stat = StudentStats.new(tag_id: chosen_tag, signups: 1)
      chosen_stat.pathway_set
      @student_stats.push(chosen_stat)
    end
  end

  def fetch_list
    @suggested_courses
  end

  def rejected_courses_ids
    rejected_ids = Set.new
    rejected_ids += StudentCourse.where(user_id: @student_id).all.map(&:course_id).to_set
    rejected_ids += Liked_course.where(user_id: @student_id).all.map(&:course_id).to_set

    @rejected_ids = rejected_ids.to_a
  end

  def fetch_courses_lists
    rejected_courses_ids
    fetch_background_info
    student_subject_courses
    all_courses
  end

  def fetch_background_info
    @bg_info = User_info.first(user_id: @student_id)
  end

  def student_subject_courses
    @subject_courses = []
    return if @bg_info&.subject.nil?

    user_subject = @bg_info.subject
    rejected_ids = @rejected_ids
    @subject_courses = Course.exclude(id: rejected_ids).where(subject: user_subject)
                             .default_suggestion_order.all
  end

  def all_courses
    user_subject = @bg_info&.subject
    rejected_ids = @rejected_ids

    @rest_of_courses = Course.exclude { Sequel.|({ id: rejected_ids }, (subject =~ user_subject)) }
                             .default_suggestion_order.all
  end

  # Suggesting courses algorithm
  def start_algorithm(quantity)
    @suggested_courses = []
    # First we sum all student tag signups
    all_signups = @student_stats.map(&:signups).sum

    if all_signups.positive?
      # Iterating through tag list containing no of signups and last signup
      @student_stats.each do |stat|
        # Take ratio of particular tag signups / all_signups and multiply by no of courses we want to have on list
        courses_no_to_fetch = stat.signups * quantity / all_signups
        # First we iterate through courses which have the same subject as student (sorting -> trusted courses first)
        # We try to take courses_no_to_fetch number of courses
        courses_no_to_fetch -= push_tag_courses(@subject_courses, stat.tag_id, courses_no_to_fetch)
        # If courses_no_to_fetch is > 0, let's take into consideration rest of the courses
        push_tag_courses(@rest_of_courses, stat.tag_id, courses_no_to_fetch)
      end
    end
    return if @student_stats.fetch(0, nil)&.pathway

    # If we didn't fill list with quantity courses, we need to fill it with most popular courses
    fill_rest_of_space(quantity) if @suggested_courses.length < quantity
  end

  def fill_rest_of_space(quantity)
    @suggested_courses += @subject_courses.take(quantity - @suggested_courses.length)
    return if @suggested_courses.length == quantity

    @suggested_courses += @rest_of_courses.take(quantity - @suggested_courses.length)
  end

  def push_tag_courses(courses_list, tag_id, quantity)
    return 0 unless courses_list.is_a?(Array) && tag_id.is_a?(Integer) && quantity.is_a?(Integer)

    pushed_courses_quantity = 0
    x = 0
    while pushed_courses_quantity <= quantity
      course = courses_list.fetch(x, nil)
      break unless course.is_a?(Course)

      x += 1
      next unless course.tag_list&.include?(tag_id)

      @suggested_courses << course
      courses_list.delete(course)
      x -= 1
      pushed_courses_quantity += 1
    end
    pushed_courses_quantity
  end

  def self.get(user_id, quantity, chosen_tag = nil)
    return nil unless student_valid?(user_id)

    new(user_id, quantity, chosen_tag)
  end

  def self.student_valid?(user_id)
    return false if user_id.nil? || !user_id.is_a?(Integer)

    user = User.first(id: user_id)
    !user.nil? && user.student?
  end
end
