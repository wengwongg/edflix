class DbHelper
  def self.set_main_tables(courses, users)
    if courses
      CoursesDbHelper.reset
      CoursesDbHelper.create_subjects
      CoursesDbHelper.create_test_courses
    end

    return unless users

    UsersDbHelper.reset
    UsersDbHelper.create_users
  end

  def self.set_student_courses
    StudentCourseDbHelper.reset
    StudentCourseDbHelper.create
  end

  def self.set_reviews
    ReviewsDbHelper.reset
    ReviewsDbHelper.create
  end

  def self.set_courses_tags
    CoursesDbHelper.reset_courses_tags
    CoursesDbHelper.create_courses_tags
  end

  def self.set_providers
    UsersDbHelper.reset_providers
    UsersDbHelper.create_providers
  end

  def self.foreign_keys(bool)
    state = if bool
              "ON"
            else
              "OFF"
            end

    DB.run("PRAGMA foreign_keys = #{state}")
  end
end
