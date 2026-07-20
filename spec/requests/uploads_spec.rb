require "rails_helper"

RSpec.describe UploadsController, type: :request do
  let(:user) { create(:user) }

  shared_examples "requires authentication" do |http_method, path_builder, params = {}|
    it "redirects to sign in" do
      path = path_builder.respond_to?(:call) ? instance_exec(&path_builder) : public_send(path_builder)
      public_send(http_method, path, params: params)

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "GET #new" do
    context "when user is not signed in" do
      include_examples "requires authentication", :get, :new_upload_path
    end

    context "when user is signed in" do
      before { sign_in user }

      it "renders the upload dropzone page", :aggregate_failures do
        get new_upload_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('data-controller="dropzone"')
        expect(response.body).to include(rails_direct_uploads_path)
      end
    end
  end

  describe "POST #create" do
    let(:signed_id) do
      ActiveStorage::Blob.create_and_upload!(
        io: StringIO.new("hello world"),
        filename: "report.pdf",
        content_type: "application/pdf"
      ).signed_id
    end

    context "when user is not signed in" do
      include_examples "requires authentication", :post, :uploads_path,
                       { library_file: { name: "report.pdf" } }
    end

    context "when user is signed in" do
      before { sign_in user }

      it "creates a library file for the current user from a signed_id", :aggregate_failures do
        expect {
          post uploads_path, params: { library_file: { name: "report.pdf", signed_id: signed_id, visibility: "public" } }
        }.to change { user.library_files.count }.by(1)

        expect(response).to have_http_status(:created)
        expect(user.library_files.last).to have_attributes(name: "report.pdf")
      end

      it "creates a private file when visibility is private" do
        post uploads_path, params: { library_file: { name: "secret.pdf", signed_id: signed_id, visibility: "private" } }

        expect(user.library_files.last.visibility_private?).to be(true)
      end

      it "creates a public file when visibility is public" do
        post uploads_path, params: { library_file: { name: "public.pdf", signed_id: signed_id, visibility: "public" } }

        expect(user.library_files.last.visibility_public?).to be(true)
      end

      it "attaches exactly the uploaded blob referenced by the signed_id" do
        blob = ActiveStorage::Blob.create_and_upload!(
          io: StringIO.new("payload"), filename: "doc.txt", content_type: "text/plain"
        )

        post uploads_path, params: { library_file: { name: "doc.txt", signed_id: blob.signed_id, visibility: "public" } }

        expect(user.library_files.order(:id).last.attachment.blob).to eq(blob)
      end

      it "rejects a create without an attachment", :aggregate_failures do
        expect {
          post uploads_path, params: { library_file: { name: "no-blob.pdf", visibility: "public" } }
        }.not_to change(LibraryFile, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
