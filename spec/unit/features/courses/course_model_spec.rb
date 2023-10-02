require_relative '../../../spec_helper'

RSpec.describe "check Course model" do
  describe "get_start_date method" do
    context "when we want to get long date in format Monday, 1 January 2020" do
      it "returns date: Friday, 1 March 2019" do
        DbHelper.set_main_tables(true, false)
        course = Course.first(id: 1)
        expect(course.get_start_date("%A, %-d %B %Y")).to eq("Friday, 1 March 2019")
      end
    end

    context "when we want to get short date in format 01/01/2020" do
      it "returns date: 01/03/2019" do
        DbHelper.set_main_tables(true, false)
        course = Course.first(id: 1)
        expect(course.get_start_date("%d/%m/%Y")).to eq("01/03/2019")
      end
    end
  end
end
