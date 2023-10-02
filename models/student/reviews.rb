class Review < Sequel::Model
  dataset_module do
    def course_reviews(course_id)
      return [] if course_id.nil? || !Validation.str_is_integer?(course_id)

      where(course_id: course_id).order(Sequel.desc(:creation_date)).all
    end
  end

  def self.add(user_id, course_id, rating, content)
    return false unless validate_add_params(user_id, course_id, rating, content)

    review = Review.first(user_id: user_id, course_id: course_id)
    if review.nil?
      review = Review.new(user_id: user_id, course_id: course_id, rating: rating.to_i, content: content,
                          creation_date: DateParse.today_utc_unix)
    else
      review.set(rating: rating.to_i, content: content, last_edited: DateParse.today_utc_unix)
    end
    review.save_changes
    true
  end

  def self.validate_add_params(user_id, course_id, rating, content)
    return false if user_id.nil? || course_id.nil? || rating.nil? || content.nil?

    user_id.is_a?(Integer) && Validation.str_is_integer?(course_id) && Validation.str_is_integer?(rating) &&
      content.is_a?(String) && !content.strip.eql?("") && (1..5).include?(rating.to_i)
  end
end
