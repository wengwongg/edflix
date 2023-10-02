require_relative "../../spec_helper"

RSpec.describe Subject do
  describe "create method" do
    context "when passed name is nil" do
      it "returns false" do
        expect(described_class.create(nil)).to be(false)
      end
    end

    context "when passed name is not a string" do
      it "returns false" do
        expect(described_class.create([])).to be(false)
      end
    end

    context "when passed name contains at least one special character" do
      it "returns false" do
        expect(described_class.create("asd123ASD#")).to be(false)
      end
    end

    context "when passed name is valid and subject of that name already exists in db" do
      it "returns false" do
        DbHelper.set_main_tables(true, false)
        expect(described_class.create("Computer Science")).to be(false)
      end
    end

    context "when passed name is valid and subject of that name does not exist in db" do
      it "returns true" do
        DbHelper.set_main_tables(true, false)
        expect(described_class.create("Biology")).to be(true)
      end

      it "creates new record in db" do
        DbHelper.set_main_tables(true, false)
        initial_size = described_class.all.length
        described_class.create("Biology")
        expect(described_class.all.length - initial_size).to eq(1)
      end
    end
  end

  describe "change_name method" do
    context "when passed name is nil" do
      it "returns false" do
        expect(described_class.first(id: 1).change_name(nil)).to be(false)
      end
    end

    context "when passed name is not a string" do
      it "returns false" do
        expect(described_class.first(id: 1).change_name([])).to be(false)
      end
    end

    context "when passed name contains at least one special character" do
      it "returns false" do
        expect(described_class.first(id: 1).change_name("asd123!ASD")).to be(false)
      end
    end

    context "when passed name is valid and subject of that name already exists in db" do
      it "returns false" do
        DbHelper.set_main_tables(true, false)
        expect(described_class.first(id: 1).change_name("Something else")).to be(false)
      end
    end

    context "when passed name is valid and subject of that name does not exist in db" do
      it "returns true" do
        DbHelper.set_main_tables(true, false)
        expect(described_class.first(id: 1).change_name("Biology")).to be(true)
      end

      it "changes name" do
        DbHelper.set_main_tables(true, false)
        described_class.first(id: 1).change_name("Biology")
        expect(described_class.first(id: 1).name).to eq("Biology")
      end
    end
  end
end
