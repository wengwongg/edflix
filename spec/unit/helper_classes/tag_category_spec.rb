require_relative "../../spec_helper"

RSpec.describe TagCategory do
  describe "initialize instance of the class" do
    context "when passed param is 'test'" do
      it "has two accessible fields: name and id which both contain 'test'" do
        new_instance = described_class.new("test")
        expect(new_instance.name).to eq(new_instance.id) && eq('test')
      end
    end
  end

  describe "validate_name method" do
    context "when passed string is nil" do
      it "returns false" do
        expect(described_class.validate_name(nil)).to be(false)
      end
    end

    context "when passed string is not a string" do
      it "returns false" do
        expect(described_class.validate_name([])).to be(false)
      end
    end

    context "when passed string contains at least one special character" do
      it "returns false" do
        expect(described_class.validate_name("some^thing")).to be(false)
      end
    end

    context "when passed string is alphanumerical" do
      it "returns true" do
        expect(described_class.validate_name("alpha019AQWE")).to be(true)
      end
    end
  end

  describe "all method" do
    context "when there are no tags in the db" do
      it "returns empty array" do
        CoursesDbHelper.reset_courses_tags
        expect(described_class.all).to match_array([])
      end
    end

    context "when there are tags in the db" do
      it "returns array containing tag types/categories, but only once" do
        DbHelper.set_courses_tags
        expect(described_class.all.map(&:name)).to contain_exactly("level", "topic")
      end
    end
  end

  describe "fetch method" do
    context "when passed param is not valid" do
      it "returns nil if param is nil" do
        DbHelper.set_courses_tags
        expect(described_class.fetch(nil)).to be_nil
      end

      it "returns nil if param is not a string" do
        DbHelper.set_courses_tags
        expect(described_class.fetch([])).to be_nil
      end

      it "returns nil if param contains at least one special character" do
        DbHelper.set_courses_tags
        expect(described_class.fetch("123asdOASJD$")).to be_nil
      end
    end

    context "when passed param is valid, but db is empty" do
      it "returns nil" do
        CoursesDbHelper.reset_courses_tags
        expect(described_class.fetch("level")).to be_nil
      end
    end

    context "when passed param is valid, but given type name does not exist in db" do
      it "returns nil" do
        DbHelper.set_courses_tags
        expect(described_class.fetch("something")).to be_nil
      end
    end

    context "when passed param is valid, but given type name exists in db" do
      it "returns TagCategory object" do
        DbHelper.set_courses_tags
        expect(described_class.fetch("level")).to match(described_class)
      end

      it "returns name param" do
        DbHelper.set_courses_tags
        expect(described_class.fetch("level").name).to eq("level")
      end
    end
  end

  describe "create method" do
    context "when given type already exists in the db" do
      it "returns false" do
        DbHelper.set_courses_tags
        expect(described_class.create("level")).to be(false)
      end
    end

    context "when given type does not exist in the db" do
      it "returns true" do
        DbHelper.set_courses_tags
        expect(described_class.create("something")).to be(true)
      end

      it "creates new tag with empty name" do
        DbHelper.set_courses_tags
        initial_length = CourseTag.all.length
        described_class.create("something")
        expect(CourseTag.all.length - initial_length).to eq(1)
      end
    end
  end

  describe "delete method" do
    it "deletes all tag ids of given type from the courses which contain them" do
      DbHelper.set_courses_tags && DbHelper.set_main_tables(true, false)
      tags_courses = Filtering.impose_tag_filters(Course.all, %w[1 2])
      described_class.fetch("level").delete
      expect(Filtering.impose_tag_filters(Course.all, %w[1 2])).not_to match_array(tags_courses)
    end
  end

  describe "change_name method" do
    context "when db is empty" do
      it "returns false" do
        CoursesDbHelper.reset_courses_tags
        expect(described_class.new("level").change_name("othername")).to be(false)
      end
    end

    context "when db is not empty and contains type: 'level'" do
      it "returns true" do
        DbHelper.set_courses_tags
        expect(described_class.new("level").change_name("othername")).to be(true)
      end

      it "changes name from 'level' to 'othername'" do
        DbHelper.set_courses_tags
        described_class.new("level").change_name("othername")
        expect(described_class.fetch("othername").name).to eq("othername")
      end
    end
  end
end
