class ReviewsDbHelper
  def self.reset
    DB[:sqlite_sequence].where(name: "reviews").delete
    DB[:reviews].delete
  end

  def self.create
    review1 = Review.new(user_id: 1, course_id: 1, rating: 5, content: "Test content 2",
                         creation_date: 1_682_726_400)
    review2 = Review.new(user_id: 1, course_id: 2, rating: 3, content: "Test content 1",
                         creation_date: 1_682_812_800)
    review3 = Review.new(user_id: 2, course_id: 2, rating: 4, content: "Test content 3",
                         creation_date: 1_682_812_800)


    review1.save_changes
    review2.save_changes
    review3.save_changes
  end
end
