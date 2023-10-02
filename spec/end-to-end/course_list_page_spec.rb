require_relative '../spec_helper'

describe "courses list page" do
  context "for empty database" do
    it "gives empty list of courses" do
      CoursesDbHelper.reset
      CoursesDbHelper.create_subjects

      visit "/courses"
      expect(page).to have_content "No courses were found"
    end
  end

  context "for non-empty database" do
    it "gives list of 4 courses" do
      DbHelper.set_main_tables(true, false)

      visit "/courses"
      expect(page).to have_content 'NameFilter TestCourse'
      expect(page).to have_content 'SubjectFilter TestCourse'
      expect(page).to have_content 'TestFilter TestCourse'
      expect(page).to have_content 'LecturerFilter TestCourse'
    end

    describe "check courses filtering by using only one filter at once" do
      it "gives list of 3 courses: NameFilter, TestFilter and LecturerFilter" do
        DbHelper.set_main_tables(true, false)

        visit "/courses"
        select "Computer Science", from: "subject"
        click_button "Filter"

        expect(page).to have_content 'NameFilter TestCourse'
        expect(page).not_to have_content 'SubjectFilter TestCourse'
        expect(page).to have_content 'TestFilter TestCourse'
        expect(page).to have_content 'LecturerFilter TestCourse'
      end

      it "gives list of 1 course: SubjectFilter" do
        DbHelper.set_main_tables(true, false)

        visit "/courses"
        select "Something else", from: "subject"
        click_button "Filter"

        expect(page).not_to have_content 'NameFilter TestCourse'
        expect(page).to have_content 'SubjectFilter TestCourse'
        expect(page).not_to have_content 'TestFilter TestCourse'
        expect(page).not_to have_content 'LecturerFilter TestCourse'
      end

      it "gives empty courses list" do
        DbHelper.set_main_tables(true, false)

        visit "/courses"
        fill_in "course_name", with: "IDoNotExist"
        click_button "Filter"

        expect(page).to have_content 'No courses were found'
      end

      it "gives list of 1 course: NameFilter" do
        DbHelper.set_main_tables(true, false)

        visit "/courses"
        fill_in "course_name", with: "name"
        click_button "Filter"

        expect(page).to have_content 'NameFilter TestCourse'
        expect(page).not_to have_content 'SubjectFilter TestCourse'
        expect(page).not_to have_content 'TestFilter TestCourse'
        expect(page).not_to have_content 'LecturerFilter TestCourse'
      end

      it "gives list of 1 course: SubjectFilter" do
        DbHelper.set_main_tables(true, false)

        visit "/courses"
        fill_in "course_name", with: "subject"
        click_button "Filter"

        expect(page).not_to have_content 'NameFilter TestCourse'
        expect(page).to have_content 'SubjectFilter TestCourse'
        expect(page).not_to have_content 'TestFilter TestCourse'
        expect(page).not_to have_content 'LecturerFilter TestCourse'
      end

      it "gives empty courses list" do
        DbHelper.set_main_tables(true, false)

        visit "/courses"
        fill_in "lecturer", with: "IDoNotExist"
        click_button "Filter"

        expect(page).to have_content 'No courses were found'
      end

      it "gives list of 1 course: LecturerFilter" do
        DbHelper.set_main_tables(true, false)

        visit "/courses"
        fill_in "lecturer", with: "Jack"
        click_button "Filter"

        expect(page).not_to have_content 'NameFilter TestCourse'
        expect(page).not_to have_content 'SubjectFilter TestCourse'
        expect(page).not_to have_content 'TestFilter TestCourse'
        expect(page).to have_content 'LecturerFilter TestCourse'
      end

      it "gives empty list" do
        DbHelper.set_main_tables(true, false)

        visit "/courses"
        fill_in "start_date", with: "2025-01-01"
        click_button "Filter"

        expect(page).to have_content 'No courses were found'
      end

      it "gives list of 3 courses: SubjectFilter, TestFilter, LecturerFilter" do
        DbHelper.set_main_tables(true, false)

        visit "/courses"
        fill_in "start_date", with: "2020-01-01"
        click_button "Filter"

        expect(page).not_to have_content 'NameFilter TestCourse'
        expect(page).to have_content 'SubjectFilter TestCourse'
        expect(page).to have_content 'TestFilter TestCourse'
        expect(page).to have_content 'LecturerFilter TestCourse'
      end

      it "gives list of 2 courses: SubjectFilter, LecturerFilter" do
        DbHelper.set_main_tables(true, false)

        visit "/courses"
        fill_in "start_date", with: "2020-01-20"
        click_button "Filter"

        expect(page).not_to have_content 'NameFilter TestCourse'
        expect(page).to have_content 'SubjectFilter TestCourse'
        expect(page).not_to have_content 'TestFilter TestCourse'
        expect(page).to have_content 'LecturerFilter TestCourse'
      end

      it "gives list of 1 course: SubjectFilter" do
        DbHelper.set_main_tables(true, false)

        visit "/courses"
        fill_in "start_date", with: "2020-03-01"
        click_button "Filter"

        expect(page).not_to have_content 'NameFilter TestCourse'
        expect(page).to have_content 'SubjectFilter TestCourse'
        expect(page).not_to have_content 'TestFilter TestCourse'
        expect(page).not_to have_content 'LecturerFilter TestCourse'
      end

      it "gives list of 1 course: SubjectFilter" do
        DbHelper.set_main_tables(true, false)

        visit "/courses"
        fill_in "start_date", with: "2020-03-01"
        click_button "Filter"

        expect(page).not_to have_content 'NameFilter TestCourse'
        expect(page).to have_content 'SubjectFilter TestCourse'
        expect(page).not_to have_content 'TestFilter TestCourse'
        expect(page).not_to have_content 'LecturerFilter TestCourse'
      end

      it "gives list of 1 course: TestFilter" do
        DbHelper.set_main_tables(true, false)

        visit "/courses"
        fill_in "start_date", with: "2020-01-01"
        check "start_date_exact"
        click_button "Filter"

        expect(page).not_to have_content 'NameFilter TestCourse'
        expect(page).not_to have_content 'SubjectFilter TestCourse'
        expect(page).to have_content 'TestFilter TestCourse'
        expect(page).not_to have_content 'LecturerFilter TestCourse'
      end
    end

    describe "check courses filtering by using multiple filters" do
      it "gives empty courses list" do
        DbHelper.set_main_tables(true, false)

        visit "/courses"
        fill_in "course_name", with: "name"
        fill_in "lecturer", with: "Jack"
        click_button "Filter"

        expect(page).to have_content 'No courses were found'
      end

      it "gives list of 2 courses: TestFilter, LecturerFilter" do
        DbHelper.set_main_tables(true, false)

        visit "/courses"
        select "Computer Science", from: "subject"
        fill_in "start_date", with: "2020-01-01"
        click_button "Filter"

        expect(page).not_to have_content 'NameFilter TestCourse'
        expect(page).not_to have_content 'SubjectFilter TestCourse'
        expect(page).to have_content 'TestFilter TestCourse'
        expect(page).to have_content 'LecturerFilter TestCourse'
      end

      it "gives list of 1 course: LecturerFilter" do
        DbHelper.set_main_tables(true, false)

        visit "/courses"
        select "Computer Science", from: "subject"
        fill_in "lecturer", with: "jack"
        fill_in "start_date", with: "2020-01-01"
        click_button "Filter"

        expect(page).not_to have_content 'NameFilter TestCourse'
        expect(page).not_to have_content 'SubjectFilter TestCourse'
        expect(page).not_to have_content 'TestFilter TestCourse'
        expect(page).to have_content 'LecturerFilter TestCourse'
      end
    end
  end
end
