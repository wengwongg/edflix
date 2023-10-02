class CoursesDbHelper
  def self.reset
    DB[:sqlite_sequence].where(name: "courses").delete
    DB[:sqlite_sequence].where(name: "subjects").delete
    DB.run('PRAGMA foreign_keys = OFF')
    DB[:courses].delete
    DB[:subjects].delete
    DB.run('PRAGMA foreign_keys = ON')
    DB[:liked_courses].delete
  end

  def self.create_subjects
    subject1 = Subject.new(name: "Computer Science")
    subject2 = Subject.new(name: "Something else")
    subject1.save_changes
    subject2.save_changes
  end

  def self.create_test_courses
    DbHelper.set_providers
    DbHelper.set_courses_tags
    course1 = Course.new(name: "NameFilter TestCourse", subject: 1, lecturer: "Prof Honey",
                         source_website: "https://google.com/", description: "Some description...", signups: 7,
                         start_date: 1_551_398_400, end_date: 1_583_020_800, duration: 1,
                         is_public: 1) # Unix timestamp for 01/03/2019 00:00:00
    course2 = Course.new(name: "SubjectFilter TestCourse", subject: 2, lecturer: "Prof Honey",
                         source_website: "https://google.com/", description: "Some description...", signups: 6,
                         start_date: 1_583_020_800, end_date: 1_583_020_800, duration: 1,
                         is_public: 1, provider: 1, tags: "1;2") # Unix timestamp for 01/03/2020 00:00:00
    course3 = Course.new(name: "TestFilter TestCourse", subject: 1, lecturer: "Prof Honey",
                         source_website: "https://google.com/", description: "Some description...", signups: 10,
                         start_date: 1_577_836_800, end_date: 1_583_020_800, duration: 1,
                         is_public: 1, tags: "1") # Unix timestamp for 01/01/2020 00:00:00 UTC
    course4 = Course.new(name: "LecturerFilter TestCourse", subject: 1, lecturer: "Prof Jack Sparrow",
                         source_website: "https://google.com/", description: "Some description...", signups: 3,
                         start_date: 1_579_478_400, end_date: 1_583_020_800, duration: 1,
                         is_public: 1, tags: "2;4") # Unix timestamp for 20/01/2020 00:00:00
    course1.save_changes
    course2.save_changes
    course3.save_changes
    course4.save_changes
  end

  def self.reset_courses_tags
    DB[:sqlite_sequence].where(name: "course_tags").delete
    CourseTag.dataset.destroy
  end

  def self.create_courses_tags
    tag1 = CourseTag.new(type: "level", name: "easy")
    tag2 = CourseTag.new(type: "level", name: "intermediate")
    tag3 = CourseTag.new(type: "level", name: "advanced")
    tag4 = CourseTag.new(type: "topic", name: "networking")
    tag5 = CourseTag.new(type: "topic", name: "software")
    tag6 = CourseTag.new(type: "topic", name: "hardware")
    tag1.save_changes
    tag2.save_changes
    tag3.save_changes
    tag4.save_changes
    tag5.save_changes
    tag6.save_changes
  end
end
