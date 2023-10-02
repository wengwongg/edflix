require_relative '../../spec_helper'

RSpec.describe Course do
  describe "get_start_date method" do
    context "when we want to get long date in format Monday, 1 January 2020" do
      it "returns date: Friday, 1 March 2019" do
        DbHelper.set_main_tables(true, false)
        course = described_class.first(id: 1)
        expect(course.get_start_date("%A, %-d %B %Y")).to eq("Friday, 1 March 2019")
      end
    end

    context "when we want to get short date in format 01/01/2020" do
      it "returns date: 01/03/2019" do
        DbHelper.set_main_tables(true, false)
        course = described_class.first(id: 1)
        expect(course.get_start_date("%d/%m/%Y")).to eq("01/03/2019")
      end
    end
  end

  describe "public? method" do
    context "when is_public record is 1" do
      it "returns true" do
        DbHelper.set_main_tables(true, false)
        course = described_class.first(id: 1)
        expect(course.public?).to be(true)
      end
    end

    context "when is_public record is 0" do
      it "returns false" do
        DbHelper.set_main_tables(true, false)
        course = described_class.new(name: "NameFilter TestCourse", subject: 1, lecturer: "Prof Honey",
                            source_website: "https://google.com/", description: "Some description...", signups: 7,
                            start_date: 1_551_398_400, end_date: 1_583_020_800, duration: 1,
                            is_public: 0)
        expect(course.public?).to be(false)
      end
    end
  end

  describe "delete method" do
    it "sets is_archived record to 1" do
      DbHelper.set_main_tables(true, false)
      course = described_class.first(id: 1)
      course.delete
      expect(course.is_archived).to eq(1)
    end
  end

  describe "restore method" do
    it "sets is_archived record to 1" do
      DbHelper.set_main_tables(true, false)
      course = described_class.first(id: 1)
      course.restore
      expect(course.is_archived).to eq(0)
    end
  end

  describe "get_date method" do
    it "returns date of passed unixtimestamp in provided format" do
      DbHelper.set_main_tables(true, false)
      course = described_class.first(id: 1)
      expect(course.get_date(1683676800, "%F")).to eq("2023-05-10")
    end
  end

  describe "id_exists? method" do
    it "returns false if id does not exist" do
      expect(described_class.id_exists?(100)).to be(false)
    end

    it "returns false if id exists" do
      DbHelper.set_main_tables(true, false)
      expect(described_class.id_exists?(1)).to be(true)
    end
  end
end
