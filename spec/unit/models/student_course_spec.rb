require_relative "../../spec_helper"

RSpec.describe StudentCourse do
  describe "filtered_student_courses method" do
    context "when passed params are not valid" do
      it "returns empty array if both params are nil" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_student_courses
        expect(described_class.filtered_student_courses(nil, nil)).to match_array([])
      end

      it "returns empty array if student_id is not an Integer" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_student_courses
        expect(described_class.filtered_student_courses("student", nil)).to match_array([])
      end

      it "returns array with 'NameFilter' and 'SubjectFilter' if second param is nil" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_student_courses
        expect(described_class.filtered_student_courses(1, nil).map do |student_course|
          Course.first(id: student_course.course_id).name
        end).to contain_exactly("NameFilter TestCourse", "SubjectFilter TestCourse")
      end
    end

    context "when passed params are valid" do
      it "returns empty array, if user of given id has never enrolled to any course" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_student_courses
        expect(described_class.filtered_student_courses(2, {})).to match_array([])
      end

      it "returns array with 'NameFilter' and 'SubjectFilter' if user is enrolled to these courses" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_student_courses
        expect(described_class.filtered_student_courses(1, {}).map do |student_course|
          Course.first(id: student_course.course_id).name
        end).to contain_exactly("NameFilter TestCourse", "SubjectFilter TestCourse")
      end

      it "returns array with 'NameFilter' only if status=1 filter is imposed" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_student_courses
        expect(described_class.filtered_student_courses(1, { "course_status" => "1" }).map do |student_course|
          Course.first(id: student_course.course_id).name
        end).to contain_exactly("NameFilter TestCourse")
      end

      it "returns array with 'NameFilter' only if enroll_date=2023-04-29 and exact filter is imposed" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_student_courses
        expect(described_class.filtered_student_courses(1,
                                                        { "enroll_date" => "2023-04-29",
                                                          "enroll_date_exact" => "" }).map do |student_course|
                 Course.first(id: student_course.course_id).name
               end).to contain_exactly("NameFilter TestCourse")
      end

      it "returns array with 'SubjectFilter' only if enroll_date=2023-04-30 is imposed" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_student_courses
        expect(described_class.filtered_student_courses(1,
                                                        { "enroll_date" => "2023-04-30" }).map do |student_course|
          Course.first(id: student_course.course_id).name
        end).to contain_exactly("SubjectFilter TestCourse")
      end

      it "returns array with 'NameFilter' only if pause_date=2023-04-29 and exact filter is imposed" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_student_courses
        expect(described_class.filtered_student_courses(1,
                                                        { "pause_date" => "2023-04-29",
                                                          "pause_date_exact" => "" }).map do |student_course|
          Course.first(id: student_course.course_id).name
        end).to contain_exactly("SubjectFilter TestCourse")
      end

      it "returns array with 'NameFilter' only if pause_date=2023-04-29 is imposed" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_student_courses
        expect(described_class.filtered_student_courses(1,
                                                        { "pause_date" => "2023-04-29" }).map do |student_course|
          Course.first(id: student_course.course_id).name
        end).to contain_exactly("SubjectFilter TestCourse")
      end

      it "returns array with 'NameFilter' only if finish_date=2023-04-29 and exact filter is imposed" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_student_courses
        expect(described_class.filtered_student_courses(1,
                                                        { "finish_date" => "2023-04-29",
                                                          "finish_date_exact" => "" }).map do |student_course|
          Course.first(id: student_course.course_id).name
        end).to contain_exactly("NameFilter TestCourse")
      end

      it "returns array with 'NameFilter' only if finish_date=2023-04-29 is imposed" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_student_courses
        expect(described_class.filtered_student_courses(1,
                                                        { "finish_date" => "2023-04-29" }).map do |student_course|
          Course.first(id: student_course.course_id).name
        end).to contain_exactly("NameFilter TestCourse")
      end
    end
  end

  describe "get_filtered_courses method" do
    context "when passed params are not valid" do
      it "returns nil if both params are nil" do
        expect(described_class.get_filtered_courses(nil, nil)).to be_nil
      end

      it "returns nil if only student_courses is nil" do
        expect(described_class.get_filtered_courses({ "name" => "NameFilter" }, nil)).to be_nil
      end

      it "returns nil if student_courses is not an array" do
        expect(described_class.get_filtered_courses({ "name" => "NameFilter" }, "test")).to be_nil
      end

      it "returns nil if student_courses is an array, but is empty" do
        expect(described_class.get_filtered_courses({ "name" => "NameFilter" }, [])).to be_nil
      end
    end

    context "when passed params are valid" do
      it "returns all courses student is enrolled to, if filters is nil" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_student_courses
        expect(described_class.get_filtered_courses(nil,
                                                    described_class.filtered_student_courses(1, nil))).to match_array(
                                                      Course.where(id: [1, 2]).all
                                                    )
      end

      it "returns 'NameFilter TestCourse' if filter['course_name']='Name' is imposed" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_student_courses
        expect(described_class.get_filtered_courses({ "course_name" => "Name" },
                                                    described_class.filtered_student_courses(1, {}))).to match_array(
                                                      Course.where(id: 1).all
                                                    )
      end
    end
  end

  describe "create_student_courses_hash method" do
    context "when passed params are not valid" do
      it "returns empty hash if both params are nil" do
        expect(described_class.create_student_courses_hash(nil, nil)).to match({})
      end

      it "returns empty hash if student_id is nil" do
        expect(described_class.create_student_courses_hash(nil, { "name" => "Name" })).to match({})
      end

      it "returns empty hash if student_id is not an Integer" do
        expect(described_class.create_student_courses_hash("student", { "name" => "Name" })).to match({})
      end
    end

    context "when passed params are valid" do
      it "returns empty hash if student was not enrolled to any course" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_student_courses
        expect(described_class.create_student_courses_hash(2, nil)).to include({})
      end

      it "returns hash with 'NameFilter' and 'SubjectFilter' courses if user is enrolled to these courses" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_student_courses
        expect(
          described_class.create_student_courses_hash(1, nil)[0].values.map(&:name)
        ).to contain_exactly("NameFilter TestCourse", "SubjectFilter TestCourse")
      end

      it "returns hash with 'NameFilter' only after imposed name filter" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_student_courses
        expect(
          described_class.create_student_courses_hash(1, { "course_name" => "Name" })[0].values.map(&:name)
        ).to contain_exactly("NameFilter TestCourse")
      end
    end
  end

  describe "enroll method" do
    context "when passed params are not valid" do
      it "returns false if both params are nil" do
        expect(described_class.enroll(nil, nil)).to be(false)
      end

      it "returns false if only first param is nil" do
        expect(described_class.enroll(nil, 2)).to be(false)
      end

      it "returns false if only second param is nil" do
        expect(described_class.enroll(1, nil)).to be(false)
      end

      it "returns false if the first param is not an Integer" do
        expect(described_class.enroll("studentid", 2)).to be(false)
      end

      it "returns false if the second param is not an Integer" do
        expect(described_class.enroll(1, "courseid")).to be(false)
      end

      it "throws Sequel::ForeignKeyConstraintViolation if provided student_id is non existing user_id" do
        DbHelper.foreign_keys(true)
        expect { described_class.enroll(100, 2) }.to raise_error(Sequel::ForeignKeyConstraintViolation)
      end

      it "return nil if provided course_id is non existing course" do
        DbHelper.foreign_keys(true)
        expect(described_class.enroll(1, 100)).to be(false)
      end
    end

    context "when passed data are valid" do
      it "returns true if both params are Integers, given ids are valid and user has never enrolled to given course" do
        expect(described_class.enroll(2, 1)).to be(true)
      end

      it "returns true if user had been enrolled to given course, but they cancelled it" do
        DbHelper.set_student_courses
        expect(described_class.enroll(1, 2)).to be(true)
      end

      it "returns false if user is already enrolled to given course" do
        DbHelper.set_student_courses
        expect(described_class.enroll(1, 1)).to be(false)
      end
    end
  end

  describe "pause method" do
    context "when course is already paused" do
      it "returns false" do
        DbHelper.set_main_tables(true, true)
        student_course = described_class.new(user_id: 1, course_id: 3, status: 2, enroll_date: 1_682_726_400)
        expect(student_course.pause).to be(false)
      end
    end

    context "when course is already completed" do
      it "returns false" do
        DbHelper.set_main_tables(true, true)
        student_course = described_class.new(user_id: 1, course_id: 3, status: 3, enroll_date: 1_682_726_400)
        expect(student_course.pause).to be(false)
      end
    end

    context "when course is enrolled to" do
      it "returns true" do
        DbHelper.set_main_tables(true, true)
        student_course = described_class.new(user_id: 1, course_id: 3, status: 1, enroll_date: 1_682_726_400)
        expect(student_course.pause).to be(true)
      end
    end
  end

  describe "resume method" do
    context "when course is already resumed" do
      it "returns false" do
        DbHelper.set_main_tables(true, true)
        student_course = described_class.new(user_id: 1, course_id: 3, status: 1, enroll_date: 1_682_690_400,
                                             pause_date: 1_682_726_400)
        expect(student_course.resume).to be(false)
      end
    end

    context "when course is already enrolled" do
      it "returns false" do
        DbHelper.set_main_tables(true, true)
        student_course = described_class.new(user_id: 1, course_id: 3, status: 1, enroll_date: 1_682_690_400)
        expect(student_course.resume).to be(false)
      end
    end

    context "when course is already completed" do
      it "returns false" do
        DbHelper.set_main_tables(true, true)
        student_course = described_class.new(user_id: 1, course_id: 3, status: 3, enroll_date: 1_682_726_400)
        expect(student_course.resume).to be(false)
      end
    end

    context "when course is paused" do
      it "returns true" do
        DbHelper.set_main_tables(true, true)
        student_course = described_class.new(user_id: 1, course_id: 3, status: 2, enroll_date: 1_682_690_400,
                                             pause_date: 1_682_726_400)
        expect(student_course.resume).to be(true)
      end
    end
  end

  describe "cancel method" do
    context "when course is already completed" do
      it "returns false" do
        DbHelper.set_main_tables(true, true)
        student_course = described_class.new(user_id: 1, course_id: 3, status: 3, enroll_date: 1_682_726_400)
        student_course.save_changes
        expect(student_course.cancel).to be(false)
      end
    end

    context "when course is paused" do
      it "returns true" do
        DbHelper.set_main_tables(true, true)
        student_course = described_class.new(user_id: 1, course_id: 3, status: 2, enroll_date: 1_682_690_400,
                                             pause_date: 1_682_726_400)
        student_course.save_changes
        expect(student_course.cancel).to be(true)
      end
    end

    context "when course has been resumed" do
      it "returns true" do
        DbHelper.set_main_tables(true, true)
        student_course = described_class.new(user_id: 1, course_id: 3, status: 1, enroll_date: 1_682_690_400,
                                             pause_date: 1_682_726_400)
        student_course.save_changes
        expect(student_course.cancel).to be(true)
      end
    end

    context "when course is enrolled to" do
      it "returns true" do
        DbHelper.set_main_tables(true, true)
        student_course = described_class.new(user_id: 1, course_id: 3, status: 1, enroll_date: 1_682_726_400)
        student_course.save_changes
        expect(student_course.cancel).to be(true)
      end
    end
  end

  describe "finish method" do
    context "when course is already completed" do
      it "returns false" do
        DbHelper.set_main_tables(true, true)
        student_course = described_class.new(user_id: 1, course_id: 3, status: 3, enroll_date: 1_682_726_400)
        expect(student_course.finish).to be(false)
      end
    end

    context "when course is paused" do
      it "returns true" do
        DbHelper.set_main_tables(true, true)
        student_course = described_class.new(user_id: 1, course_id: 3, status: 2, enroll_date: 1_682_690_400,
                                             pause_date: 1_682_726_400)
        expect(student_course.finish).to be(true)
      end
    end

    context "when course has been resumed" do
      it "returns true" do
        DbHelper.set_main_tables(true, true)
        student_course = described_class.new(user_id: 1, course_id: 3, status: 1, enroll_date: 1_682_690_400,
                                             pause_date: 1_682_726_400)
        expect(student_course.finish).to be(true)
      end
    end

    context "when course is enrolled to" do
      it "returns true" do
        DbHelper.set_main_tables(true, true)
        student_course = described_class.new(user_id: 1, course_id: 3, status: 1, enroll_date: 1_682_726_400)
        expect(student_course.finish).to be(true)
      end
    end
  end
end
