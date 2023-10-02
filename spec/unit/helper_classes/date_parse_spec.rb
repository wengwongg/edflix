require_relative "../../spec_helper"

RSpec.describe DateParse do
  context "check if date is parsed from unixtimestamp" do
    it "returns parsed unix timestamp 1588032000 as 2020-04-28" do
      parsed_date = described_class.parse_unix_to_date(1_588_032_000, "%F")
      expect(parsed_date).to eql("2020-04-28")
    end
  end

  context "check if unixtimestamp is parsed from date string" do
    it "returns parsed date string 2018-05-01 as 1525132800" do
      parsed_date_int = described_class.parse_date_to_unix("2018-05-01")
      expect(parsed_date_int).to eq(1_525_132_800)
    end
  end
end
