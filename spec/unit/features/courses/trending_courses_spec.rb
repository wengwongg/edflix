require_relative '../../../spec_helper'

RSpec.describe "get trending courses" do
  context "get only 1 most trending course" do
    it "returns course called 'TestFilter TestCourse'" do
      DbHelper.set_main_tables(true, false)
      StudentCourseDbHelper.reset

      trending_courses = Course.get_trending_courses(1)
      expect(trending_courses.length).to be(1)
      expect(trending_courses.fetch(0).name).to eql("TestFilter TestCourse")
    end
  end

  context "get 3 most trending course in order from the most trending to the least trending" do
    it "returns list in the following order: 'TestFilter TestCourse', 'NameFilter TestCourse', 'SubjectFilter TestCourse'" do
      DbHelper.set_main_tables(true, false)
      StudentCourseDbHelper.reset

      trending_courses = Course.get_trending_courses(3)
      expect(trending_courses.length).to be(3)
      expect(trending_courses.fetch(0).name).to eql("TestFilter TestCourse")
      expect(trending_courses.fetch(1).name).to eql("NameFilter TestCourse")
      expect(trending_courses.fetch(2).name).to eql("SubjectFilter TestCourse")
    end
  end
end
