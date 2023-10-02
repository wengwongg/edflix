require_relative '../../spec_helper'

RSpec.describe Provider do
  describe "create method" do
    context "when name is nil" do
      it "returns false" do
        expect(described_class.create(nil)).to be(false)
      end
    end

    context "when provider of given name already exist" do
      it "returns false" do
        DbHelper.set_providers
        expect(described_class.create("Test provider")).to be(false)
      end
    end

    context "when name contains special characters" do
      it "returns false" do
        expect(described_class.create("Test^ing")).to be(false)
      end
    end

    context "when name does not exist in database and is valid" do
      it "returns true" do
        expect(described_class.create("Testing new provider")).to be(true)
      end
    end
  end

  describe "change_name method" do
    context "when name is nil" do
      it "returns false" do
        provider = described_class.new(name: "Testing a provider")
        expect(provider.change_name(nil)).to be(false)
      end
    end

    context "when provider of given name already exist" do
      it "returns false" do
        DbHelper.set_providers
        provider = described_class.new(name: "Testing a provider")
        expect(provider.change_name("Test provider")).to be(false)
      end
    end

    context "when name contains special characters" do
      it "returns false" do
        provider = described_class.new(name: "Testing a provider")
        expect(provider.change_name("Test^ing")).to be(false)
      end
    end

    context "when name does not exist in database and is valid" do
      it "returns true" do
        DbHelper.set_providers
        provider = described_class.new(name: "Testing a provider")
        expect(provider.change_name("Testing different name")).to be(true)
      end
    end
  end
end
