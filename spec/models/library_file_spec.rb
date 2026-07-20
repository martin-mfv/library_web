require "rails_helper"

RSpec.describe LibraryFile, type: :model do
  subject(:library_file) { build(:library_file) }

  describe "validations" do
    it "is valid with default factory attributes", :aggregate_failures do
      expect(library_file).to be_valid
      expect(library_file.attachment).to be_attached
    end

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(255) }

    it "is invalid without an attachment", :aggregate_failures do
      record = build(:library_file, :without_attachment)

      expect(record).to be_invalid
      expect(record.errors[:attachment]).to be_present
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:copied_from).class_name("LibraryFile").optional }

    it { is_expected.to have_many(:copies).class_name("LibraryFile").with_foreign_key(:copied_from_id).dependent(:nullify) }

    it "has one attached attachment" do
      expect(library_file.attachment).to be_an_instance_of(ActiveStorage::Attached::One)
    end

    it "links a copy back to its source and lists it among the source's copies", :aggregate_failures do
      source = create(:library_file)
      copy = create(:library_file, copied_from: source)

      expect(copy.copied_from).to eq(source)
      expect(source.copies).to include(copy)
    end

    it "nullifies copies when the source is destroyed" do
      source = create(:library_file)
      copy = create(:library_file, copied_from: source)

      source.destroy

      expect(copy.reload.copied_from_id).to be_nil
    end
  end

  describe "#visibility" do
    it "is an integer-backed private/public enum with auto scopes disabled" do
      expect(library_file).to define_enum_for(:visibility)
        .with_values(private: 0, public: 1)
        .backed_by_column_of_type(:integer)
        .with_prefix(:visibility)
    end

    it "defaults to public" do
      expect(described_class.new.visibility).to eq("public")
    end
  end

  describe "#byte_size" do
    it "derives byte_size from the attachment blob" do
      record = create(:library_file)

      expect(record.byte_size).to eq(record.attachment.blob.byte_size)
    end
  end

  describe "#content_type" do
    it "derives content_type from the attachment blob" do
      record = create(:library_file)

      expect(record.content_type).to eq(record.attachment.blob.content_type)
    end
  end
end
