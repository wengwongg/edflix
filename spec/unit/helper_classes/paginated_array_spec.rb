require_relative "../../spec_helper"

RSpec.describe PaginatedArray do
  describe "initialize instance of the class" do
    context "when both params are nil" do
      it "@array is empty" do
        object = described_class.new(nil, nil)
        expect(object.all_elements).to match_array([])
      end

      it "@elements_per_age is 5" do
        object = described_class.new(nil, nil)
        expect(object.elements_per_page).to eq(5)
      end

      it "@last_page is 1" do
        object = described_class.new(nil, nil)
        expect(object.last_page).to eq(1)
      end
    end

    context "when first param is not valid" do
      it "@array is empty if passed array is nil" do
        object = described_class.new(nil, { "page_size" => 10 })
        expect(object.all_elements).to match_array([])
      end

      it "@elements_per_age is 10 if passed array is nil" do
        object = described_class.new(nil, { "page_size" => 10 })
        expect(object.elements_per_page).to eq(10)
      end

      it "@last_page is 1 if passed array is nil" do
        object = described_class.new(nil, { "page_size" => 10 })
        expect(object.last_page).to eq(1)
      end

      it "@array is empty if passed array is a String" do
        object = described_class.new("array", { "page_size" => 10 })
        expect(object.all_elements).to match_array([])
      end

      it "@elements_per_age is 10 if passed array is a String" do
        object = described_class.new("array", { "page_size" => 10 })
        expect(object.elements_per_page).to eq(10)
      end

      it "@last_page is 1 if passed array is a String" do
        object = described_class.new("array", { "page_size" => 10 })
        expect(object.last_page).to eq(1)
      end
    end

    context "when second param is not valid" do
      it "@array is equal to passed array if passed elements_per_page is nil" do
        object = described_class.new([1, 3, 5, 7, 9, 11], nil)
        expect(object.all_elements).to contain_exactly(1, 3, 5, 7, 9, 11)
      end

      it "@elements_per_age is 5 if passed elements_per_page is nil" do
        object = described_class.new([1, 3, 5, 7, 9, 11], nil)
        expect(object.elements_per_page).to eq(5)
      end

      it "@last_page is 1 if passed elements_per_page is nil" do
        object = described_class.new([1, 3, 5, 7, 9, 11], nil)
        expect(object.last_page).to eq(2)
      end

      it "@array is equal to passed array if passed elements_per_page is not an Integer" do
        object = described_class.new([1, 3, 5, 7, 9, 11], { "page_size" => "integer" })
        expect(object.all_elements).to contain_exactly(1, 3, 5, 7, 9, 11)
      end

      it "@elements_per_age is 5 if passed elements_per_page is not an Integer" do
        object = described_class.new([1, 3, 5, 7, 9, 11], { "page_size" => "integer" })
        expect(object.elements_per_page).to eq(5)
      end

      it "@last_page is 1 if passed elements_per_page is not an Integer" do
        object = described_class.new([1, 3, 5, 7, 9, 11], { "page_size" => "integer" })
        expect(object.last_page).to eq(2)
      end
    end

    context "when both params are valid" do
      it "@array is equal to the passed array" do
        object = described_class.new([1, 3, 5, 7, 9, 11, 4, 15, 12, 10, 32, 14, 16], { "page_size" => 6 })
        expect(object.all_elements).to contain_exactly(1, 3, 5, 7, 9, 11, 4, 15, 12, 10, 32, 14, 16)
      end

      it "@elements_per_page should equal 6" do
        object = described_class.new([1, 3, 5, 7, 9, 11, 4, 15, 12, 10, 32, 14, 16], { "page_size" => 6 })
        expect(object.elements_per_page).to eq(6)
      end

      it "@last_page should be equal to 3 if there are 13 records in array and elements_per_page=6" do
        object = described_class.new([1, 3, 5, 7, 9, 11, 4, 15, 12, 10, 32, 14, 16], { "page_size" => 6 })
        expect(object.last_page).to eq(3)
      end

      it "@last_page should be equal to 2 if there are 12 records in array and elements_per_page=6" do
        object = described_class.new([1, 3, 5, 7, 9, 11, 4, 15, 12, 10, 32, 14], { "page_size" => 6 })
        expect(object.last_page).to eq(2)
      end

      it "get_paged_array should be [4, 15, 12, 10, 32, 14] if page_no=2" do
        object = described_class.new([1, 3, 5, 7, 9, 11, 4, 15, 12, 10, 32, 14, 16],
                                     { "page_size" => 6, "page" => 2 })
        expect(object.paginated_array).to contain_exactly(4, 15, 12, 10, 32, 14)
      end

      it "get_paged_array should be [1, 3, 5, 7, 9, 11] if page_no=nil" do
        object = described_class.new([1, 3, 5, 7, 9, 11, 4, 15, 12, 10, 32, 14, 16],
                                     { "page_size" => 6 })
        expect(object.paginated_array).to contain_exactly(1, 3, 5, 7, 9, 11)
      end

      it "get_paged_array should be [11, 4, 15, 12, 10] if page_no=2 and elements_per_page=4 (min value=5)" do
        object = described_class.new([1, 3, 5, 7, 9, 11, 4, 15, 12, 10, 32, 14, 16],
                                     { "page_size" => 4, "page" => 2 })
        expect(object.paginated_array).to contain_exactly(11, 4, 15, 12, 10)
      end

      it "get_paged_array should be [32, 14, 16] if page_no=100 and elements_per_page=5" do
        object = described_class.new([1, 3, 5, 7, 9, 11, 4, 15, 12, 10, 32, 14, 16],
                                     { "page_size" => 5, "page" => 100 })
        expect(object.paginated_array).to contain_exactly(32, 14, 16)
      end
    end
  end

  describe "first_displayed method" do
    it "returns 2 if page=6" do
      object = described_class.new([1, 3, 5, 7, 9, 11, 4, 15, 12, 10, 32, 14,
                                    16, 1, 3, 5, 7, 9, 11, 4, 15, 12, 10, 32, 14, 16],
                                   { "page_size" => 5, "page" => 6 })
      expect(object.first_displayed).to eq(2)
    end

    it "returns 1 if page=3" do
      object = described_class.new([1, 3, 5, 7, 9, 11, 4, 15, 12, 10, 32, 14,
                                    16, 1, 3, 5, 7, 9, 11, 4, 15, 12, 10, 32, 14, 16],
                                   { "page_size" => 5, "page" => 3 })
      expect(object.first_displayed).to eq(1)
    end

    it "returns 1 if page=3" do
      object = described_class.new([1, 3, 5, 7, 9, 11, 4, 15, 12, 10, 32, 14, 16],
                                   { "page_size" => 5, "page" => 3 })
      expect(object.first_displayed).to eq(1)
    end
  end

  describe "last_displayed method" do
    it "returns 6 if page=6" do
      object = described_class.new([1, 3, 5, 7, 9, 11, 4, 15, 12, 10, 32, 14,
                                    16, 1, 3, 5, 7, 9, 11, 4, 15, 12, 10, 32, 14, 16],
                                   { "page_size" => 5, "page" => 6 })
      expect(object.last_displayed).to eq(6)
    end

    it "returns 5 if page=3" do
      object = described_class.new([1, 3, 5, 7, 9, 11, 4, 15, 12, 10, 32, 14,
                                    16, 1, 3, 5, 7, 9, 11, 4, 15, 12, 10, 32, 14, 16],
                                   { "page_size" => 5, "page" => 3 })
      expect(object.last_displayed).to eq(5)
    end
  end
end
