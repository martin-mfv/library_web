require "rails_helper"

RSpec.describe LibraryFiles::CopyService do
  describe "#call" do
    let(:owner) { create(:user) }
    let(:actor) { create(:user) }
    let(:source) { create_library_file(user: owner, name: "Source.pdf", bytes: 256) }

    it "creates a private copy linked to source and returns the copied record", :aggregate_failures do
      copied_file = described_class.new(source_file: source, actor: actor).call

      expect(copied_file).to be_persisted
      expect(copied_file.name).to eq("Source.pdf (copy)")
      expect(copied_file.visibility).to eq("private")
      expect(copied_file.copied_from).to eq(source)
    end

    it "reuses the same attachment blob for speed and storage efficiency" do
      copied_file = described_class.new(source_file: source, actor: actor).call

      expect(copied_file.attachment.blob).to eq(source.attachment.blob)
    end

    it "keeps copied file attachment when source file is deleted" do
      copied_file = described_class.new(source_file: source, actor: actor).call

      source.destroy

      expect(copied_file.reload.attachment).to be_attached
    end

    it "returns nil when copy cannot be persisted" do
      allow_any_instance_of(LibraryFile).to receive(:save).and_return(false)

      copied_file = described_class.new(source_file: source, actor: actor).call

      expect(copied_file).to be_nil
    end
  end
end
