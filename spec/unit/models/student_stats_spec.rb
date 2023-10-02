require_relative '../../spec_helper'

RSpec.describe StudentStats do
  describe "pathway_set method" do
    it "sets pathway field to true" do
      DbHelper.set_main_tables(false, true)
      DbHelper.set_courses_tags
      stat = described_class.new(user_id: 1, tag_id: 1, last_update: DateParse.today_utc_unix)
      stat.pathway_set
      expect(stat.pathway).to be(true)
    end
  end

  describe "increment_stats method" do
    context "when passed student_stat does not exist in db" do
      it "creates new record in db with signups==1" do
        DbHelper.set_main_tables(false, true)
        DbHelper.set_courses_tags
        described_class.increment_stats(described_class.first(user_id: 100), 1, 1)
        expect(described_class.first(user_id: 1, tag_id: 1).signups).to eq(1)
      end
    end

    context "when passed student_stat exists in db" do
      it "increments signups for existing record by 1" do
        DbHelper.set_main_tables(false, true)
        DbHelper.set_courses_tags
        described_class.increment_stats(nil, 1, 1)
        described_class.increment_stats(described_class.first(user_id: 1, tag_id: 1), 1, 1)
        expect(described_class.first(user_id: 1, tag_id: 1).signups).to eq(2)
      end
    end
  end

  describe "decrement_stats method" do
    context "when passed student_stat does not exist in db" do
      it "returns function" do
        expect(described_class.decrement_stats(described_class.first(user_id: 100))).to be_nil
      end
    end

    context "when passed student_stat exists in db" do
      it "decrements signups for existing record by 1" do
        DbHelper.set_main_tables(false, true)
        DbHelper.set_courses_tags
        described_class.increment_stats(nil, 1, 1)
        described_class.decrement_stats(described_class.first(user_id: 1, tag_id: 1))
        expect(described_class.first(user_id: 1, tag_id: 1).signups).to eq(0)
      end
    end

    context "when passed student_stat exists in db and signups==0" do
      it "does nothing" do
        DbHelper.set_main_tables(false, true)
        DbHelper.set_courses_tags
        described_class.increment_stats(nil, 1, 1)
        described_class.decrement_stats(described_class.first(user_id: 1, tag_id: 1))
        described_class.decrement_stats(described_class.first(user_id: 1, tag_id: 1))
        expect(described_class.first(user_id: 1, tag_id: 1).signups).to eq(0)
      end
    end
  end

  describe "performs_stats_action method" do
    context "when passed course has no tags" do
      it "does nothing" do
        DB[:student_stats].delete
        DbHelper.set_main_tables(true, true)
        DbHelper.set_courses_tags
        described_class.perform_stats_action(1, Course.first(id: 1), "increment")
        expect(described_class.first(user_id: 1)).to be_nil
      end
    end

    context "when passed course has one tag" do
      it "creates new record for a user with that tag and signups=1" do
        DB[:student_stats].delete
        DbHelper.set_courses_tags
        DbHelper.set_main_tables(true, true)
        described_class.perform_stats_action(1, Course.first(id: 3), "increment")
        expect(described_class.first(user_id: 1).tag_id).to eq(1)
      end
    end

    context "when passed course has one two tags" do
      it "creates 2 new records for a user for each tag" do
        DB[:student_stats].delete
        DbHelper.set_courses_tags
        DbHelper.set_main_tables(true, true)
        described_class.perform_stats_action(1, Course.first(id: 2), "increment")
        expect(described_class.where(user_id: 1).all.size).to eq(2)
      end
    end

    context "when passed action is neither 'increment' not 'decrement'" do
      it "returns nil" do
        DB[:student_stats].delete
        DbHelper.set_courses_tags
        DbHelper.set_main_tables(true, true)
        expect(described_class.perform_stats_action(1, Course.first(id: 2), "nothing")).to be_nil
      end
    end
  end

  describe "count_completed_courses method" do
    context "when student_courses is nil" do
      it "returns 0" do
        expect(described_class.count_completed_courses(nil)).to eq(0)
      end
    end

    context "when student_courses is empty" do
      it "returns 0" do
        expect(described_class.count_completed_courses(StudentCourse.first(user_id: 100))).to eq(0)
      end
    end

    context "when student_courses has one completed course" do
      it "returns 1" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_student_courses
        expect(described_class.count_completed_courses(StudentCourse.where(user_id: 1).all)).to eq(1)
      end
    end
  end

  describe "count_enrolled_courses method" do
    context "when student_courses is nil" do
      it "returns 0" do
        expect(described_class.count_enrolled_courses(1, nil)).to eq(0)
      end
    end

    context "when student_courses is empty" do
      it "returns 0" do
        expect(described_class.count_enrolled_courses(1, StudentCourse.first(user_id: 100))).to eq(0)
      end
    end

    context "when student_courses has one enrolled course" do
      it "returns 1" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_student_courses
        expect(described_class.count_enrolled_courses(1, StudentCourse.where(user_id: 1).all)).to eq(1)
      end
    end
  end

  describe "total_reviews method" do
    it "returns 2 for user_id=1" do
      DbHelper.set_main_tables(true, true)
      DbHelper.set_reviews
      expect(described_class.total_reviews(1)).to eq(2)
    end
  end
end