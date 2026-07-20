FactoryBot.define do
  factory :library_file do
    name { Faker::File.file_name(dir: "", ext: "txt") }
    # visibility defaults to :public via the DB/enum default; override per example.
    association :user

    # Attach a small real file by default so the record is valid and blob-derived
    # helpers (byte_size / uploaded_at / content_type) have something to read.
    transient do
      with_attachment { true }
    end

    after(:build) do |library_file, evaluator|
      if evaluator.with_attachment
        library_file.attachment.attach(
          Rack::Test::UploadedFile.new(
            Rails.root.join("spec/fixtures/files/sample.txt"), "text/plain"
          )
        )
      end
    end

    # Build/create a record with no attachment (e.g. to exercise the presence validation).
    trait :without_attachment do
      with_attachment { false }
    end
  end
end
