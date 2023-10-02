class StudentStats < Sequel::Model(:student_stats)
  dataset_module do
    def all_sorted_stats(user_id)
      return nil if user_id.nil?

      where(user_id: user_id).order_by_latest_preferred.all
    end

    def order_by_latest_preferred
      order { |o| o.last_update < (DateParse.today_utc_date - 7).to_i }
        .order_append(Sequel.desc(:signups))
    end
  end

  def pathway_set
    @pathway = true
  end

  def self.increment_stats(student_stat, user_id, tag_id)
    if student_stat.nil?
      student_stat = StudentStats.new(user_id: user_id, tag_id: tag_id, last_update: DateParse.today_utc_unix,
                                      signups: 0)
    end
    student_stat.signups += 1
    student_stat.save_changes
  end

  def self.decrement_stats(student_stat)
    return if student_stat.nil?

    student_stat.signups -= 1 if student_stat.signups.positive?
    student_stat.save_changes
  end

  def self.perform_stats_action(user_id, course, action)
    tags = []
    tags += course.tag_list unless course.tag_list.nil?

    tags.each do |tag|
      student_stat = StudentStats.first(user_id: user_id, tag_id: tag)
      case action
      when "increment"
        increment_stats(student_stat, user_id, tag)
      when "decrement"
        decrement_stats(student_stat)
      else
        break
      end
    end
  end

  def self.count_completed_courses(student_courses)
    return 0 if student_courses.nil? || student_courses.empty?

    student_courses.select { |course| course.status.eql?(3) }.length
  end

  def self.count_enrolled_courses(completed_courses_size, student_courses)
    return 0 if student_courses.nil? || student_courses.empty?

    student_courses.length - completed_courses_size
  end

  def self.total_reviews(user_id)
    Review.where(user_id: user_id).all.length
  end

  attr_accessor :pathway
end
