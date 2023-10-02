require_relative '../../spec_helper'

RSpec.describe SuggestedCourses do
  describe "get method" do
    context "when user_id does not exist in db" do
      it "returns nil" do
        expect(described_class.get(100, 2)).to be_nil
      end
    end

    context "when user_id exists in db but is not a student" do
      it "returns nil" do
        DbHelper.set_main_tables(true, true)
        expect(described_class.get(2, 2)).to be_nil
      end
    end

    context "when user_id exists in db and is a student" do
      it "returns SuggestedCourses object" do
        DbHelper.set_main_tables(true, true)
        expect(described_class.get(1, 2)).to be_an_instance_of(described_class)
      end
    end
  end

  describe "fetch_list method" do
    context "when student has never enrolled in any course and set any subject" do
      it "returns list of most popular courses" do
        DB[:student_stats].delete
        DbHelper.set_main_tables(true, true)
        o = described_class.get(1, 5)
        expect(o.fetch_list.map(&:name)).to match_array(Course.get_popular_courses(5).map(&:name))
      end
    end

    context "when student has never enrolled in any course and has set a subject=1" do
      it "returns list based on student subject" do
        DB[:student_stats].delete
        DbHelper.set_main_tables(true, true)
        User_info.new(user_id: 1, subject: 1).save_changes
        o = described_class.get(1, 5)
        expect(o.fetch_list.map(&:name)).to eq(["TestFilter TestCourse", "NameFilter TestCourse",
                                                "LecturerFilter TestCourse", "SubjectFilter TestCourse"])
      end
    end

    context "when student has enrolled in course=4 and has set a subject=1" do
      it "returns list based on student subject" do
        DB[:student_stats].delete
        DbHelper.set_main_tables(true, true)
        User_info.new(user_id: 1, subject: 1).save_changes
        StudentCourse.enroll(1, 4)
        o = described_class.get(1, 5)
        expect(o.fetch_list.map(&:name)).to eq(["SubjectFilter TestCourse", "TestFilter TestCourse", "NameFilter TestCourse"])
      end
    end

    context "when student has enrolled in course=4 and has set a subject=1 and chosen tag=2" do
      it "returns list based on student subject" do
        DB[:student_stats].delete
        DbHelper.set_main_tables(true, true)
        User_info.new(user_id: 1, subject: 1).save_changes
        o = described_class.get(1, 5, 2)
        expect(o.fetch_list.map(&:name)).to eq(["LecturerFilter TestCourse", "SubjectFilter TestCourse"])
      end
    end
  end
end