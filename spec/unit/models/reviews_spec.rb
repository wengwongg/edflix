require_relative "../../spec_helper"

RSpec.describe Review do
  describe "course_reviews method" do
    context "when passed param is not valid" do
      it "returns empty array when passed param is nil" do
        expect(described_class.course_reviews(nil)).to match_array([])
      end

      it "returns empty array when passed param is not an integer" do
        expect(described_class.course_reviews("course")).to match_array([])
      end
    end

    context "when passed param is valid" do
      it "returns empty array if user has not any reviews" do
        DbHelper.set_main_tables(true, true)
        ReviewsDbHelper.reset
        expect(described_class.course_reviews("1")).to match_array([])
      end

      it "returns array containing two reviews" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_reviews
        expect(described_class.course_reviews("2").map(&:content)).to contain_exactly("Test content 1",
                                                                                      "Test content 3")
      end
    end
  end

  describe "add method" do
    context "when passed data are not valid" do
      it "returns false when first param is nil" do
        expect(described_class.add(nil, "1", "5", "content")).to be(false)
      end

      it "returns false when first param is not an Integer" do
        expect(described_class.add("user_id", "1", "5", "content")).to be(false)
      end

      it "returns false when second param is nil" do
        expect(described_class.add(1, nil, "5", "content")).to be(false)
      end

      it "returns false when second param is not a number in String" do
        expect(described_class.add(1, "course_id", "5", "content")).to be(false)
      end

      it "returns false when third param is nil" do
        expect(described_class.add(1, "1", nil, "content")).to be(false)
      end

      it "returns false when third param is not a number in String" do
        expect(described_class.add(1, "1", "rating", "content")).to be(false)
      end

      it "returns false when fourth param is nil" do
        expect(described_class.add(1, "1", "5", nil)).to be(false)
      end
    end

    context "when all params are valid and db is empty" do
      it "returns true" do
        DbHelper.set_main_tables(true, true)
        ReviewsDbHelper.reset
        expect(described_class.add(1, "1", "5", "some content")).to be(true)
      end

      it "creates new record in db" do
        DbHelper.set_main_tables(true, true)
        ReviewsDbHelper.reset
        described_class.add(1, "1", "5", "some content")
        expect(described_class.first(user_id: 1, course_id: 1)).not_to be_nil
      end
    end

    context "when all params are valid and review which we are trying to add already exist" do
      it "returns true" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_reviews
        expect(described_class.add(1, "1", "5", "changed content")).to be(true)
      end

      it "changes existing record in the database" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_reviews
        review = described_class.first(user_id: 1, course_id: 1)
        described_class.add(1, "1", "5", "changed content")
        expect(described_class.first(user_id: 1, course_id: 1).content).not_to eq(review.content)
      end
    end
  end

  describe "deleting review" do
    context "when user is not logged in" do
      it "returns error" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_reviews
        delete "/courses/2/review"

        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq('http://example.org/courses/2')
        expect(session[:error]).to eq("You must be logged in to delete a review.")
      end
    end

    context "when user is logged in, but has no permissions to delete own reviews" do
      it "returns error" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_reviews
        delete "/courses/2/review", {}, { "rack.session" => { id: 2 } }

        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq('http://example.org/courses/2')
        expect(session[:error]).to eq("You don't have enough permissions to delete your reviews.")
      end
    end

    context "when user is logged in, has enough permissions, but does not have a review for this course" do
      it "returns error" do
        DbHelper.set_main_tables(true, true)
        ReviewsDbHelper.reset
        delete "/courses/2/review", {}, { "rack.session" => { id: 1 } }

        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq('http://example.org/courses/2')
        expect(session[:error]).to eq("You cannot delete your review if it does not exist.")
      end
    end

    context "when user is logged in, has enough permissions, and has a review for this course" do
      it "returns info indicating that review is deleted successfully" do
        DbHelper.set_main_tables(true, true)
        DbHelper.set_reviews
        delete "/courses/2/review", {}, { "rack.session" => { id: 1 } }

        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq('http://example.org/courses/2')
        expect(session[:info]).to eq("Your review has been deleted.")
      end
    end
  end
end
