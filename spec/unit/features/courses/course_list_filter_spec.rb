require_relative "../../../spec_helper"

RSpec.describe "Course list filters" do
  describe "Course.filter_results(params)" do
    context "with name filter imposed on courses list (filter looks for the whole words, not collection of letters)" do
      it "respond body does include course named 'NameFilter TestCourse' only and does not include other courses" do
        DbHelper.set_main_tables(true, false)

        get "/courses?course_name=NameFilter"
        expect(last_response.body).to include("<td>NameFilter TestCourse</td>")
        expect(last_response.body).not_to include(
          "<td>SubjectFilter TestCourse</td>",
          "<td>TestFilter TestCourse</td>",
          "<td>LecturerFilter TestCourse</td>"
        )
      end

      it "respond body does include courses which end with 'TestCourse'" do
        DbHelper.set_main_tables(true, false)

        get "/courses?name=TestCourse"
        expect(last_response.body).to include(
          "<td>NameFilter TestCourse</td>",
          "<td>SubjectFilter TestCourse</td>",
          "<td>TestFilter TestCourse</td>",
          "<td>LecturerFilter TestCourse</td>"
        )
      end
    end

    context "with subject filter imposed on courses list" do
      it "uses the subject which does not exists in the database (filter won't work and all courses will be displayed)" do
        DbHelper.set_main_tables(true, false)

        get "/courses?subject=IDoNotExist"
        expect(last_response.body).to include(
          "<td>NameFilter TestCourse</td>",
          "<td>SubjectFilter TestCourse</td>",
          "<td>TestFilter TestCourse</td>",
          "<td>LecturerFilter TestCourse</td>"
        )
      end

      it "uses the subject Computer Science which exists in the database. It should not include course named 'SubjectFilter TestCourse'" do
        DbHelper.set_main_tables(true, false)

        get "/courses?subject=1"
        expect(last_response.body).not_to include("<td>SubjectFilter TestCourse</td>")
        expect(last_response.body).to include(
          "<td>NameFilter TestCourse</td>",
          "<td>TestFilter TestCourse</td>",
          "<td>LecturerFilter TestCourse</td>"
        )
      end

      it "uses the subject Something else which exists in the database. It should include course named 'SubjectFilter TestCourse and exclude the rest'" do
        CoursesDbHelper.reset
        CoursesDbHelper.create_subjects
        CoursesDbHelper.create_test_courses

        get "/courses?subject=2"
        expect(last_response.body).to include("<td>SubjectFilter TestCourse</td>")
        expect(last_response.body).not_to include(
          "<td>NameFilter TestCourse</td>",
          "<td>TestFilter TestCourse</td>",
          "<td>LecturerFilter TestCourse</td>"
        )
      end
    end

    context "with lecturer filter imposed on courses list (filter looks for the whole words, not collection of letters)" do
      it "checks lecturer which does not exist." do
        DbHelper.set_main_tables(true, false)

        get "/courses?lecturer=Spiderman"
        expect(last_response.body).to include("<p>No courses were found</p>")
      end

      it "checks lecturer who's name includes 'Jack Sparrow'" do
        DbHelper.set_main_tables(true, false)

        get "/courses?lecturer=Jack+Sparrow"
        expect(last_response.body).to include("<td>LecturerFilter TestCourse</td>")
        expect(last_response.body).not_to include(
          "<td>NameFilter TestCourse</td>",
          "<td>TestFilter TestCourse</td>",
          "<td>SubjectFilter TestCourse</td>"
        )
      end

      it "checks lecturer who's name includes 'Honey'" do
        DbHelper.set_main_tables(true, false)

        get "/courses?lecturer=Honey"
        expect(last_response.body).not_to include("<td>LecturerFilter TestCourse</td>")
        expect(last_response.body).to include(
          "<td>NameFilter TestCourse</td>",
          "<td>TestFilter TestCourse</td>",
          "<td>SubjectFilter TestCourse</td>"
        )
      end
    end

    context "with start_date filter imposed on the courses list" do
      it "includes only year 2025 which should give empty list" do
        DbHelper.set_main_tables(true, false)

        get "/courses?start_date=2025-01-01"
        expect(last_response.body).to include("<p>No courses were found</p>")
      end

      it "includes only year 2019 which should give all courses" do
        DbHelper.set_main_tables(true, false)

        get "/courses?start_date=2019-01-01"
        expect(last_response.body).to include(
          "<td>LecturerFilter TestCourse</td>",
          "<td>NameFilter TestCourse</td>",
          "<td>TestFilter TestCourse</td>",
          "<td>SubjectFilter TestCourse</td>"
        )
      end

      it "includes only year 2020 which should exclude 'NameFilter TestCourse'" do
        DbHelper.set_main_tables(true, false)

        get "/courses?start_date=2020-01-01"
        expect(last_response.body).to include(
          "<td>LecturerFilter TestCourse</td>",
          "<td>TestFilter TestCourse</td>",
          "<td>SubjectFilter TestCourse</td>"
        )
        expect(last_response.body).not_to include("<td>NameFilter TestCourse</td>")
      end

      it "includes year 2020 and month 3 which should include 'SubjectFilter TestCourse' only" do
        DbHelper.set_main_tables(true, false)

        get "/courses?start_date=2020-03-01"
        expect(last_response.body).to include("<td>SubjectFilter TestCourse</td>")
        expect(last_response.body).not_to include(
          "<td>LecturerFilter TestCourse</td>",
          "<td>NameFilter TestCourse</td>",
          "<td>TestFilter TestCourse</td>"
        )
      end

      it "includes year 2020, month 1 and day 15 which should exclude 'NameFilter TestCourse' and 'TestFilter TestCourse'" do
        DbHelper.set_main_tables(true, false)

        get "/courses?start_date=2020-01-15"
        expect(last_response.body).to include(
          "<td>LecturerFilter TestCourse</td>",
          "<td>SubjectFilter TestCourse</td>"
        )
        expect(last_response.body).not_to include(
          "<td>TestFilter TestCourse</td>",
          "<td>NameFilter TestCourse</td>"
        )
      end

      it "includes year 2020, month 1 and day 1 with exact checkbox checked which should include 'TestFilter TestCourse' only (exact date)" do
        DbHelper.set_main_tables(true, false)

        get "/courses?start_date=2020-01-01&start_date_exact=1"
        expect(last_response.body).to include("<td>TestFilter TestCourse</td>")
        expect(last_response.body).not_to include(
          "<td>LecturerFilter TestCourse</td>",
          "<td>SubjectFilter TestCourse</td>",
          "<td>NameFilter TestCourse</td>"
        )
      end

      it "includes only year 2019 which should give all courses" do
        DbHelper.set_main_tables(true, false)

        get "/courses?end_date=2019-01-01"
        expect(last_response.body).to include(
                                        "<td>LecturerFilter TestCourse</td>",
                                        "<td>NameFilter TestCourse</td>",
                                        "<td>TestFilter TestCourse</td>",
                                        "<td>SubjectFilter TestCourse</td>"
                                      )
      end

      it "includes only 2020-03-01 which should give all courses" do
        DbHelper.set_main_tables(true, false)

        get "/courses?end_date=2020-03-01&end_date_exact=1"
        expect(last_response.body).to include(
                                        "<td>LecturerFilter TestCourse</td>",
                                        "<td>NameFilter TestCourse</td>",
                                        "<td>TestFilter TestCourse</td>",
                                        "<td>SubjectFilter TestCourse</td>"
                                      )
      end
    end
  end
end
