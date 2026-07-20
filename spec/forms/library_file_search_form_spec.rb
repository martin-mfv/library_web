require "rails_helper"

RSpec.describe LibraryFileSearchForm do
  let(:user) { create(:user) }
  let(:index_url) { { action: :index } }
  let(:relation) { user.library_files }
  let(:form) { described_class.new(relation, index_url) }

  describe "#url" do
    it "returns provided url" do
      expect(form.url).to eq(action: :index)
    end

    it "supports alternate url" do
      shared_form = described_class.new(relation, { action: :shared_with_me })

      expect(shared_form.url).to eq(action: :shared_with_me)
    end
  end

  describe "#method" do
    it "returns get" do
      expect(form.method).to eq(:get)
    end
  end

  describe "#sorted_by?" do
    it "returns true when column is active sort" do
      name_form = described_class.new(relation, index_url, sort: "name")

      expect(name_form.sorted_by?("name")).to be(true)
    end

    it "returns false when column is not active sort" do
      name_form = described_class.new(relation, index_url, sort: "name")

      expect(name_form.sorted_by?("size")).to be(false)
    end
  end

  describe "#direction_for" do
    context "when column is active and current direction is asc" do
      it "returns desc" do
        name_form = described_class.new(relation, index_url, sort: "name", direction: "asc")

        expect(name_form.direction_for("name")).to eq("desc")
      end
    end

    context "when column is inactive" do
      it "returns asc" do
        name_form = described_class.new(relation, index_url, sort: "name", direction: "asc")

        expect(name_form.direction_for("size")).to eq("asc")
      end
    end
  end

  describe "#search!" do
    context "when filtering by q" do
      it "matches names case-insensitively and drops non-matches", :aggregate_failures do
        match = create_library_file(user: user, name: "Quarterly Report.pdf")
        create_library_file(user: user, name: "Vacation.png")
        results = described_class.new(relation, index_url, q: "quarterly").search!

        expect(results.pluck(:name)).to contain_exactly("Quarterly Report.pdf")
        expect(results).to include(match)
      end

      it "returns everything when q is blank" do
        create_library_file(user: user, name: "A")
        create_library_file(user: user, name: "B")

        expect(described_class.new(relation, index_url, q: "").search!.count).to eq(2)
      end

      it "treats like wildcards in q as literals" do
        create_library_file(user: user, name: "100% Cotton.txt")
        create_library_file(user: user, name: "Report.txt")

        expect(described_class.new(relation, index_url, q: "100%").search!.pluck(:name)).to contain_exactly("100% Cotton.txt")
      end
    end

    context "when relation is injected" do
      it "scopes results to the provided relation" do
        mine = create_library_file(user: user, name: "Mine.txt")
        create_library_file(user: create(:user), name: "Theirs.txt")

        expect(described_class.new(relation, index_url).search!).to contain_exactly(mine)
      end

      it "works with custom relation" do
        mine = create_library_file(user: user, name: "Mine.txt")
        shared = create_library_file(user: create(:user), name: "Shared.txt")
        shared_relation = LibraryFile.visibility_public.where(id: [ shared.id, mine.id ]).where.not(user_id: user.id)

        expect(described_class.new(shared_relation, index_url).search!).to contain_exactly(shared)
      end
    end

    context "when sorting by name" do
      before do
        create_library_file(user: user, name: "banana")
        create_library_file(user: user, name: "apple")
        create_library_file(user: user, name: "cherry")
      end

      it "supports asc" do
        expect(described_class.new(relation, index_url, sort: "name", direction: "asc").search!.pluck(:name)).to eq(%w[apple banana cherry])
      end

      it "supports desc" do
        expect(described_class.new(relation, index_url, sort: "name", direction: "desc").search!.pluck(:name)).to eq(%w[cherry banana apple])
      end
    end

    context "when sorting by size" do
      let!(:small) { create_library_file(user: user, name: "small", bytes: 10) }
      let!(:big) { create_library_file(user: user, name: "big", bytes: 5_000) }
      let!(:mid) { create_library_file(user: user, name: "mid", bytes: 500) }

      it "supports asc" do
        expect(described_class.new(relation, index_url, sort: "size", direction: "asc").search!.to_a).to eq([ small, mid, big ])
      end

      it "supports desc" do
        expect(described_class.new(relation, index_url, sort: "size", direction: "desc").search!.to_a).to eq([ big, mid, small ])
      end
    end

    context "when sorting by date" do
      let!(:oldest) { create_library_file(user: user, name: "oldest", at: 3.days.ago) }
      let!(:newest) { create_library_file(user: user, name: "newest", at: 1.hour.ago) }
      let!(:middle) { create_library_file(user: user, name: "middle", at: 1.day.ago) }

      it "supports asc" do
        expect(described_class.new(relation, index_url, sort: "date", direction: "asc").search!.to_a).to eq([ oldest, middle, newest ])
      end

      it "supports desc" do
        expect(described_class.new(relation, index_url, sort: "date", direction: "desc").search!.to_a).to eq([ newest, middle, oldest ])
      end
    end

    context "when sort key is unknown" do
      it "raises key error" do
        invalid_form = described_class.new(relation, index_url, sort: "bogus", direction: "bogus")

        expect { invalid_form.search! }.to raise_error(KeyError)
      end
    end
  end
end
