require_relative '../../spec_helper'

RSpec.describe CourseTag do
  describe "all_tags_hash method" do
    context "when course_tags table is empty" do
      it "returns empty hash" do
        CoursesDbHelper.reset_courses_tags
        expect(described_class.all_tags_hash).to match({})
      end
    end

    context "when course_tags table has only one type of tags" do
      it "returns hash with only one key" do
        CoursesDbHelper.reset_courses_tags
        tag1 = described_class.new(type: "type1", name: "name1").save_changes
        tag2 = described_class.new(type: "type1", name: "name2").save_changes
        expect(described_class.all_tags_hash).to match({ "type1" => [tag1, tag2] })
      end
    end

    context "when course_tags table has two types of tags" do
      it "returns hash containing two keys" do
        DbHelper.set_courses_tags
        type1 = described_class.where(type: "level").all
        type2 = described_class.where(type: "topic").all
        expect(described_class.all_tags_hash).to match({ "level" => type1, "topic" => type2 })
      end
    end
  end

  describe "extract_tags_from_params method" do
    context "when param is nil" do
      it "returns nil" do
        expect(described_class.extract_tags_from_params(nil)).to be_nil
      end
    end

    context "when param has has no keys starting with 'course_tag'" do
      it "returns nil" do
        expect(described_class.extract_tags_from_params({ "course_name" => "name" })).to be_nil
      end
    end

    context "when param has one key starting with 'course_tag' which value is 3" do
      it "returns array containing 3 only" do
        expect(described_class.extract_tags_from_params({ "course_name" => "name",
                                                          "course_tag_some" => "3" })).to contain_exactly("3")
      end
    end

    context "when param has two keys starting with 'course_tag' which values are 4 and 5" do
      it "returns array containing 4 and 5 only" do
        expect(described_class.extract_tags_from_params({ "course_name" => "name",
                                                          "course_tag_some" => "4",
                                                          "course_tag_else" => "5" })).to contain_exactly("4", "5")
      end
    end

    context "when param has two keys starting with 'course_tag' which values are [4,2] and [5,7]" do
      it "returns array containing 4, 5, 2 and 7 only" do
        expect(described_class.extract_tags_from_params({ "course_name" => "name",
                                                          "course_tag_some" => %w[4 2],
                                                          "course_tag_else" => %w[5 7] })).to contain_exactly(
                                                            "4", "5", "2", "7"
                                                          )
      end
    end
  end

  describe "provided_tags_exist? method" do
    context "when provided param is nil" do
      it "returns true" do
        expect(described_class.provided_tags_exist?(nil)).to be(true)
      end
    end

    context "when provided param is valid" do
      it "returns false if param is a value that does not exist in db" do
        DbHelper.set_courses_tags
        expect(described_class.provided_tags_exist?("100")).to be(false)
      end

      it "returns true if param is a value that exists in db" do
        DbHelper.set_courses_tags
        expect(described_class.provided_tags_exist?("1")).to be(true)
      end

      it "returns false if param contains at least one value that does not exist in db" do
        DbHelper.set_courses_tags
        expect(described_class.provided_tags_exist?("1;100")).to be(false)
      end

      it "returns true if param contains values which all exist in db" do
        DbHelper.set_courses_tags
        expect(described_class.provided_tags_exist?("1;2;3")).to be(true)
      end
    end
  end

  describe "name_valid? method" do
    context "when passed param is nil" do
      it "returns false" do
        expect(described_class.name_valid?(nil)).to be(false)
      end
    end

    context "when passed param is not a string" do
      it "returns false" do
        expect(described_class.name_valid?(10)).to be(false)
      end
    end

    context "when passed param contains at least one special character" do
      it "returns false" do
        expect(described_class.name_valid?("somest%ring")).to be(false)
      end
    end

    context "when passed param is alphanumerical" do
      it "returns true" do
        expect(described_class.name_valid?("Some st1ring 123")).to be(true)
      end
    end
  end

  describe "could_create? method" do
    context "when passed name is not valid" do
      it "returns false if name is nil" do
        DbHelper.set_courses_tags
        DbHelper.set_main_tables(true, true)
        expect(described_class.could_create?("topic", nil)).to be(false)
      end

      it "returns false if name is not a string" do
        DbHelper.set_courses_tags
        DbHelper.set_main_tables(true, true)
        expect(described_class.could_create?("topic", [])).to be(false)
      end

      it "returns false if name contains at least one special character" do
        DbHelper.set_courses_tags
        DbHelper.set_main_tables(true, true)
        expect(described_class.could_create?("topic", "asjhdgasjdg$asdasASD")).to be(false)
      end
    end

    context "when passed type is not valid" do
      it "returns false if type is nil" do
        DbHelper.set_courses_tags
        DbHelper.set_main_tables(true, true)
        expect(described_class.could_create?(nil, "tagname")).to be(false)
      end
    end

    context "when passed params are valid" do
      it "returns false if passed type does not exist" do
        DbHelper.set_courses_tags
        DbHelper.set_main_tables(true, true)
        expect(described_class.could_create?("noexist", "tagname")).to be(false)
      end

      it "returns true if passed type exists and name is unique (for given type)" do
        DbHelper.set_courses_tags
        DbHelper.set_main_tables(true, true)
        expect(described_class.could_create?("level", "extreme")).to be(true)
      end

      it "returns true if passed type exists and name is unique for given type, but not for all tags" do
        DbHelper.set_courses_tags
        DbHelper.set_main_tables(true, true)
        expect(described_class.could_create?("level", "networking")).to be(true)
      end

      it "returns false if passed type exists and name is not unique for given type" do
        DbHelper.set_courses_tags
        DbHelper.set_main_tables(true, true)
        expect(described_class.could_create?("topic", "networking")).to be(false)
      end
    end
  end

  describe "create method" do
    context "when given type/category (which exists) includes no tags" do
      it "only one record with name=nil for given type exists in the db and name is overwritten with provided one" do
        CoursesDbHelper.reset_courses_tags
        empty_type = described_class.new(type: "sometype", name: nil)
        empty_type.save_changes
        described_class.create("sometype", "somename")
        expect(described_class.first(id: empty_type.id).name).to eq("somename")
      end
    end

    context "when given type/category (which exists) includes at least one tag" do
      it "only one record with name=nil for given type exists in the db and name is overwritten with provided one" do
        DbHelper.set_courses_tags
        initial_length = described_class.all.length
        described_class.create("level", "somename")
        expect(described_class.all.length - initial_length).to eq(1)
      end
    end
  end

  describe "delete method" do
    context "when 2 courses include provided tag" do
      it "deletes tag id from courses which include it" do
        DbHelper.set_courses_tags
        DbHelper.set_main_tables(true, false)
        list = Filtering.impose_tag_filters(Course.all, ["1"])
        described_class.first(id: "1").delete
        expect(Filtering.impose_tag_filters(Course.all, ["1"])).not_to match_array(list)
      end
    end
  end

  describe "change_name method" do
    context "when given name is already taken by other tag (of the same type)" do
      it "returns false" do
        DbHelper.set_courses_tags
        tag = described_class.first(id: "1")
        expect(tag.change_name("advanced")).to be(false)
      end
    end

    context "when given name is already taken by other tag (of different type)" do
      it "returns true" do
        DbHelper.set_courses_tags
        tag = described_class.first(id: "1")
        expect(tag.change_name("networking")).to be(true)
      end

      it "changes name of tag" do
        DbHelper.set_courses_tags
        tag = described_class.first(id: "1")
        described_class.first(id: "1").change_name("networking")
        expect(tag.name).not_to eq(described_class.first(id: "1").name)
      end
    end

    context "when given name is not taken by any tags" do
      it "returns true" do
        DbHelper.set_courses_tags
        tag = described_class.first(id: "1")
        expect(tag.change_name("something else")).to be(true)
      end

      it "changes name of tag" do
        DbHelper.set_courses_tags
        tag = described_class.first(id: "1")
        described_class.first(id: "1").change_name("something else")
        expect(tag.name).not_to eq(described_class.first(id: "1").name)
      end
    end
  end
end
