class StudentCourse < Sequel::Model(:student_courses)
  def pause
    return false if status.eql?(3) || status.eql?(2)

    set(status: 2, pause_date: DateParse.today_utc_unix)
    save_changes
    true
  end

  def resume
    return false if status.eql?(3) || status.eql?(1)

    set(status: 1, pause_date: DateParse.today_utc_unix)
    save_changes
    true
  end

  def cancel
    return false if status.eql?(3)

    course = Course.first(id: course_id)
    course.signups -= 1
    course.save_changes
    StudentStats.perform_stats_action(user_id, course, "decrement")

    delete
    true
  end

  def finish
    return false if status.eql?(3)

    set(status: 3, finish_date: DateParse.today_utc_unix)
    save_changes
    true
  end

  dataset_module do
    def trending_student_courses
      week_in_advance = (DateParse.today_utc_date - 7).to_i

      order { |o| o.enroll_date >= week_in_advance }.all
    end

    def filtered_student_courses(student_id, params)
      return [] if student_id.nil? || !student_id.is_a?(Integer)

      dataset = where(user_id: student_id)
      return dataset.sort_default.all if params.nil?

      dataset = dataset.where(status: params['course_status'].to_i) if !params['course_status'].nil? &&
                                                                       [1, 2, 3,
                                                                        4].include?(params['course_status'].to_i)

      unless params['enroll_date'].nil?
        parsed_date = DateParse.parse_date_to_unix(params['enroll_date'])
        unless parsed_date.nil?
          # Here we check if "Exact?" checkbox was ticked. If yes we don't get date starting from the given date
          # but only exact date
          dataset = if params['enroll_date_exact']
                      dataset.where(enroll_date: parsed_date)
                    else
                      dataset.where(enroll_date: parsed_date..)
                    end
        end
      end

      unless params['pause_date'].nil?
        parsed_date = DateParse.parse_date_to_unix(params['pause_date'])
        unless parsed_date.nil?
          dataset = if params['pause_date_exact']
                      dataset.where(pause_date: parsed_date)
                    else
                      dataset.where(pause_date: parsed_date..)
                    end
        end
      end

      unless params['finish_date'].nil?
        parsed_date = DateParse.parse_date_to_unix(params['finish_date'])
        unless parsed_date.nil?
          dataset = if params['finish_date_exact']
                      dataset.where(finish_date: parsed_date)
                    else
                      dataset.where(finish_date: parsed_date..)
                    end
        end
      end

      dataset.sort_default.all
    end

    def sort_default
      order { |o| o.status >= 3 }
        .order_append(Sequel.desc(:finish_date))
        .order_append(Sequel.desc(:enroll_date))
    end
  end

  def self.get_filtered_courses(filters, student_courses)
    return nil if student_courses.nil? || !student_courses.is_a?(Array) || student_courses.empty?

    courses_ids = student_courses.map(&:course_id)
    return Course.where(id: courses_ids).all if filters.nil?

    Filtering.courses(filters, courses_ids)
  end

  def self.create_student_courses_hash(student_id, filters)
    return {} if student_id.nil? || !student_id.is_a?(Integer)

    student_courses_hash = {}
    # First we filter student courses
    all_student_courses = filtered_student_courses(student_id, filters)
    # We also filter courses separately
    filtered_courses = get_filtered_courses(filters, all_student_courses)
    # Then we eliminate all student courses which ids are not included in filtered_courses list
    filtered_student_courses = Filtering.student_courses(filtered_courses, all_student_courses)
    # Then we paginate resulting filtered array
    paginated_student_courses = PaginatedArray.new(filtered_student_courses, filters)

    # Now create hash where the key is StudentCourse object and value is Course - no need to fetch again from db
    paginated_student_courses.paginated_array.each do |student_course|
      filtered_courses&.each do |course|
        student_courses_hash[student_course] = course if student_course.course_id == course.id
      end
    end

    # Return array where first element is created hash, and second element are pagination details (for view)
    [student_courses_hash, paginated_student_courses]
  end

  def self.enroll(student_id, course_id)
    return false if student_id.nil? || !student_id.is_a?(Integer) || course_id.nil? || !course_id.is_a?(Integer)

    course = Course.first(id: course_id)
    student_course = StudentCourse.first(user_id: student_id, course_id: course_id)
    if course.nil? || (!student_course.nil? && (student_course.status.eql?(1) || student_course.status.eql?(2)))
      return false
    end

    if student_course.nil?
      student_course = StudentCourse.new(user_id: student_id, course_id: course_id, status: 1,
                                         enroll_date: DateParse.today_utc_unix)
      course.signups += 1
      course.save_changes
    else
      student_course.set(status: 1, enroll_date: DateParse.today_utc_unix,
                         finish_date: nil, pause_date: nil)
    end
    student_course.save_changes
    StudentStats.perform_stats_action(student_id, course, "increment")
    true
  end
end
