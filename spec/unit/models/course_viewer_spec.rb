require_relative '../../spec_helper'

RSpec.describe CourseViewer do
  describe "can_view_course? method" do
    context "when passed user_id is nil" do
      it "returns false" do
        expect(described_class.can_view_course?(nil, 1)).to be(false)
      end
    end

    context "when passed course_id is nil" do
      it "returns false" do
        expect(described_class.can_view_course?(1, nil)).to be(false)
      end
    end

    context "when user has permissions to view a given course" do
      it "returns true" do
        DbHelper.set_main_tables(true, true)
        described_class.new(user_id: 1, course_id: 1).save_changes
        expect(described_class.can_view_course?(1, 1)).to be(true)
      end
    end

    context "when user has no permissions to view a given course" do
      it "returns true" do
        DB[:course_viewers].delete
        DbHelper.set_main_tables(true, true)
        expect(described_class.can_view_course?(1, 1)).to be(false)
      end
    end
  end

  describe "create method" do
    context "when provided course_id does not exist" do
      it "returns nil" do
        expect(described_class.create(%w[1 2 100], 100)).to be_nil
      end
    end

    context "when provided user_ids is not an array" do
      it "returns nil" do
        DbHelper.set_main_tables(true, false)
        expect(described_class.create("1", "1")).to be_nil
      end
    end

    context "when provided params are valid" do
      it "adds course_viewers for given users who exist in db" do
        DbHelper.set_main_tables(true, true)
        DB[:course_viewers].delete
        described_class.create(%w[1 2 100], "1")
        expect(described_class.where(course_id: 1).all.length).to eq(2)
      end

      it "removes course_viewer for given course when user_id are not provided in user_ids array" do
        DbHelper.set_main_tables(true, true)
        DB[:course_viewers].delete
        described_class.create(%w[1 2 100], "1")
        described_class.create(["1"], "1")
        expect(described_class.where(course_id: 1).all.length).to eq(1)
      end
    end
  end

  describe "extract_viewers_from_params method" do
    context "when params is nil" do
      it "returns nil" do
        expect(described_class.extract_viewers_from_params(nil)).to be_nil
      end
    end

    context "when params do not contain key starting with 'course_viewer'" do
      it "returns empty array" do
        expect(described_class.extract_viewers_from_params({ "name" => "Some name" })).to match_array([])
      end
    end

    context "when params contain one key starting with 'course_viewer'" do
      it "returns array of lenght=1" do
        expect(described_class.extract_viewers_from_params({ "name" => "Some name",
                                                             "course_viewer-1" => ["1"] }).length).to eq(1)
      end
    end
  end
end
