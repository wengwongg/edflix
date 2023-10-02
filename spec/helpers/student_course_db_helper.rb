class StudentCourseDbHelper
  def self.reset
    DB[:sqlite_sequence].where(name: "student_courses").delete
    DB[:student_courses].delete
  end

  def self.create
    student_course1 = StudentCourse.new(user_id: 1, course_id: 1, status: 1,
                                        enroll_date: 1_682_726_400, finish_date: 1_682_726_400)
    student_course2 = StudentCourse.new(user_id: 1, course_id: 2, status: 3,
                                        enroll_date: 1_682_812_800, pause_date: 1_682_726_400)
    student_course1.save_changes
    student_course2.save_changes
  end
end
