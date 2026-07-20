require "rails_helper"

RSpec.describe LibraryFiles::ChangeVisibilityService do
  describe "#call" do
    it "changes visibility from public to private and returns true", :aggregate_failures do
      file = create(:library_file, visibility: :public)

      result = described_class.new(file: file).call

      expect(result).to be(true)
      expect(file.reload.visibility).to eq("private")
    end

    it "changes visibility from private to public and returns true", :aggregate_failures do
      file = create(:library_file, visibility: :private)

      result = described_class.new(file: file).call

      expect(result).to be(true)
      expect(file.reload.visibility).to eq("public")
    end

    it "returns false when update fails" do
      file = create(:library_file, visibility: :public)
      allow(file).to receive(:update).and_return(false)

      result = described_class.new(file: file).call

      expect(result).to be(false)
    end
  end
end
