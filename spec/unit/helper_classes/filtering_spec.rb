require_relative "../../spec_helper"

RSpec.describe Filtering do
  describe "courses method" do
    context "when no params are passed" do
      it "returns array containing all courses" do
        DbHelper.set_main_tables(true, false)
        returned_courses = described_class.courses(nil, nil)
        expect(returned_courses).to eq(Course.default_order.all)
      end
    end

    context "when no filtering params and courses_ids of 1 and 4 are passed" do
      it "returns array containing only 'NameFilter TestCourse' and 'LecturerFilter TestCourse' courses objects" do
        DbHelper.set_main_tables(true, false)
        returned_courses = described_class.courses(nil, [1, 4])
        expect(returned_courses.map(&:name)).to include("LecturerFilter TestCourse", "NameFilter TestCourse")
      end
    end

    context "when filtering subject=2 param and no courses_ids are passed" do
      it "returns array containing only 'SubjectFilter TestCourse'" do
        DbHelper.set_main_tables(true, false)
        returned_courses = described_class.courses({ "subject" => 2 }, nil)
        expect(returned_courses.map(&:name)).to contain_exactly("SubjectFilter TestCourse")
      end
    end

    context "when filtering subject=2 param and courses_ids of 1 and 4 are passed" do
      it "returns empty array" do
        DbHelper.set_main_tables(true, false)
        returned_courses = described_class.courses({ "subject" => 2 }, [1, 4])
        expect(returned_courses).to match_array([])
      end
    end

    context "when filtering subject=1 param and courses_ids of 1, 2 and 4 are passed" do
      it "returns array containing only 'SubjectFilter TestCourse'" do
        DbHelper.set_main_tables(true, false)
        returned_courses = described_class.courses({ "subject" => 2 }, [1, 2, 4])
        expect(returned_courses.map(&:name)).to contain_exactly("SubjectFilter TestCourse")
      end
    end
  end

  describe "student_courses method" do
    context "when any of params is nil" do
      it "returns empty array when both params are empty" do
        DbHelper.set_main_tables(true, false)
        returned_student_courses = described_class.student_courses(nil, nil)
        expect(returned_student_courses).to match_array([])
      end

      it "returns empty array when first param only is empty" do
        DbHelper.set_main_tables(true, false)
        returned_student_courses = described_class.student_courses(nil, StudentCourse.all)
        expect(returned_student_courses).to match_array([])
      end

      it "returns empty array when second param only is empty" do
        DbHelper.set_main_tables(true, false)
        returned_student_courses = described_class.student_courses(Course.all, nil)
        expect(returned_student_courses).to match_array([])
      end
    end

    context "when any of params is not an array or an empty array" do
      it "returns empty array when first param is not an array" do
        DbHelper.set_main_tables(true, false)
        returned_student_courses = described_class.student_courses("something", StudentCourse.all)
        expect(returned_student_courses).to match_array([])
      end

      it "returns empty array when second param is not an array" do
        DbHelper.set_main_tables(true, false)
        returned_student_courses = described_class.student_courses(Course.all, "something else")
        expect(returned_student_courses).to match_array([])
      end

      it "returns empty array when first param is an empty array" do
        DbHelper.set_main_tables(true, false)
        returned_student_courses = described_class.student_courses([], StudentCourse.all)
        expect(returned_student_courses).to match_array([])
      end

      it "returns empty array when second param is an empty array" do
        DbHelper.set_main_tables(true, false)
        returned_student_courses = described_class.student_courses(Course.all, [])
        expect(returned_student_courses).to match_array([])
      end
    end

    context "when all params are valid" do
      it "returns array containing 'NameFilter TestCourse' and 'TestFilter TestCourse' courses" do
        DbHelper.set_main_tables(true, false)
        DbHelper.set_student_courses
        returned_student_courses = described_class.student_courses(Course.all, StudentCourse.where(id: [1, 2]).all)
        expect(returned_student_courses.map(&:course_id)).to contain_exactly(1, 2)
      end

      it "returns array containing 'NameFilter TestCourse' only" do
        DbHelper.set_main_tables(true, false)
        DbHelper.set_student_courses
        returned_student_courses = described_class.student_courses([Course.first(id: 1)],
                                                                   StudentCourse.where(id: [1, 2]).all)
        expect(returned_student_courses.map(&:course_id)).to contain_exactly(1)
      end

      it "returns array containing 'TestFilter TestCourse' only" do
        DbHelper.set_main_tables(true, false)
        DbHelper.set_student_courses
        returned_student_courses = described_class.student_courses(Course.all, [StudentCourse.first(id: 2)])
        expect(returned_student_courses.map(&:course_id)).to contain_exactly(2)
      end
    end
  end

  describe "any_courses_filters_imposed? method" do
    context "with no params passed" do
      it "returns false" do
        response = described_class.any_courses_filters_imposed?(nil)
        expect(response).to be(false)
      end
    end

    context "with at least one param passed" do
      it "returns true when only name is provided" do
        response = described_class.any_courses_filters_imposed?("course_name" => "test")
        expect(response).to be(true)
      end

      it "returns true when only start_date is provided" do
        response = described_class.any_courses_filters_imposed?("start_date" => "2020-01-10")
        expect(response).to be(true)
      end

      it "returns true when only lecturer is provided" do
        response = described_class.any_courses_filters_imposed?("lecturer" => "someone")
        expect(response).to be(true)
      end

      it "returns true when only subject (which exist!) is provided" do
        CoursesDbHelper.reset
        CoursesDbHelper.create_subjects
        response = described_class.any_courses_filters_imposed?("subject" => "1")
        expect(response).to be(true)
      end
    end

    context "with one param passed which is not valid" do
      it "returns false when name is an empty string" do
        response = described_class.any_courses_filters_imposed?("name" => "")
        expect(response).to be(false)
      end

      it "returns false when lecturer is an empty string" do
        response = described_class.any_courses_filters_imposed?("lecturer" => "")
        expect(response).to be(false)
      end

      it "returns false when subject for given id does not exist" do
        CoursesDbHelper.reset
        CoursesDbHelper.create_subjects
        response = described_class.any_courses_filters_imposed?("subject" => "100")
        expect(response).to be(false)
      end
    end

    context "with many params where at least one of them is valid" do
      it "returns true when subject is not valid and name is valid" do
        CoursesDbHelper.reset
        CoursesDbHelper.create_subjects
        response = described_class.any_courses_filters_imposed?("subject" => "100", "course_name" => "test2")
        expect(response).to be(true)
      end
    end
  end

  describe "impose_tag_filters method" do
    context "when filtered_courses is invalid" do
      it "returns empty array if filtered_courses is nil" do
        DbHelper.set_courses_tags
        DbHelper.set_main_tables(true, false)
        expect(described_class.impose_tag_filters(nil, %w[1 2])).to match_array([])
      end

      it "returns empty array if filtered_courses is not an array" do
        DbHelper.set_courses_tags
        DbHelper.set_main_tables(true, false)
        expect(described_class.impose_tag_filters("some text", %w[1 2])).to match_array([])
      end
    end

    context "when params is invalid" do
      it "returns filtered_courses in state it was passed if params is nil" do
        DbHelper.set_courses_tags
        DbHelper.set_main_tables(true, false)
        expect(described_class.impose_tag_filters(Course.all, nil)).to match_array(Course.all)
      end
    end

    context "when both params are valid" do
      it "returns empty array when no course matches provided tag=3" do
        DbHelper.set_courses_tags
        DbHelper.set_main_tables(true, false)
        expect(described_class.impose_tag_filters(Course.all, ["3"])).to match_array([])
      end

      it "returns array containing two courses: 'SubjectFilter TestCourse' and 'LecturerFilter TestCourse' for tag=2" do
        DbHelper.set_courses_tags
        DbHelper.set_main_tables(true, false)
        expect(described_class.impose_tag_filters(Course.all, ["2"]).map(&:name)).to contain_exactly(
          "SubjectFilter TestCourse", "LecturerFilter TestCourse"
        )
      end

      it "returns array containing two courses: 'SubjectFilter TestCourse' and 'TestFilter TestCourse' for tag=1" do
        DbHelper.set_courses_tags
        DbHelper.set_main_tables(true, false)
        expect(described_class.impose_tag_filters(Course.all, ["1"]).map(&:name)).to contain_exactly(
          "SubjectFilter TestCourse", "TestFilter TestCourse"
        )
      end

      it "returns array containing only 'SubjectFilter TestCourse' for combined tags=[1, 2]" do
        DbHelper.set_courses_tags
        DbHelper.set_main_tables(true, false)
        expect(described_class.impose_tag_filters(Course.all, %w[1 2]).map(&:name)).to contain_exactly(
          "SubjectFilter TestCourse"
        )
      end
    end
  end
end
