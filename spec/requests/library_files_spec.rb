require "rails_helper"

RSpec.describe LibraryFilesController, type: :request do
  let(:user) { create(:user) }

  shared_examples "requires authentication" do |path_helper, params = {}|
    it "redirects to sign in" do
      get public_send(path_helper), params: params

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "GET #index" do
    context "when user is not signed in" do
      include_examples "requires authentication", :root_path
    end

    context "when user is signed in" do
      before { sign_in user }

      context "with files from multiple users" do
        before do
          create_library_file(user: user, name: "MyReport.pdf")
          create_library_file(user: create(:user), name: "SomeoneElse.pdf")
        end

        it "lists only the signed-in user's files", :aggregate_failures do
          get root_path

          expect(response).to have_http_status(:ok)
          expect(response.body).to include("MyReport.pdf")
          expect(response.body).not_to include("SomeoneElse.pdf")
        end
      end

      context "with current user's file" do
        it "shows owner as Me" do
          create_library_file(user: user, name: "Mine.txt")

          get root_path

          expect(response.body).to include("Me")
        end
      end

      context "when filtering by q" do
        it "returns only matched files", :aggregate_failures do
          create_library_file(user: user, name: "Invoice-2026.pdf")
          create_library_file(user: user, name: "Holiday.png")

          get root_path, params: { q: "invoice" }

          expect(response.body).to include("Invoice-2026.pdf")
          expect(response.body).not_to include("Holiday.png")
        end
      end

      context "when sorting by name asc" do
        it "orders rows by name ascending" do
          create_library_file(user: user, name: "Zebra.txt")
          create_library_file(user: user, name: "Apple.txt")

          get root_path, params: { sort: "name", direction: "asc" }

          expect(response.body.index("Apple.txt")).to be < response.body.index("Zebra.txt")
        end
      end

      context "when sorting by size desc" do
        it "orders rows by size descending" do
          create_library_file(user: user, name: "Tiny.txt", bytes: 5)
          create_library_file(user: user, name: "Huge.txt", bytes: 9_000)

          get root_path, params: { sort: "size", direction: "desc" }

          expect(response.body.index("Huge.txt")).to be < response.body.index("Tiny.txt")
        end
      end

      context "with 25 files" do
        before { 25.times { |i| create_library_file(user: user, name: format("file-%02d.txt", i)) } }

        it "shows all 25 files on page 1 with default Kaminari settings", :aggregate_failures do
          get root_path, params: { sort: "name", direction: "asc", page: 1 }

          expect(response.body).to include("file-00.txt")
          expect(response.body).to include("file-24.txt")
        end

        it "shows no file rows on page 2", :aggregate_failures do
          get root_path, params: { sort: "name", direction: "asc", page: 2 }

          expect(response.body).to include("No files here yet")
          expect(response.body).not_to include("file-00.txt")
        end
      end
    end
  end

  describe "GET #shared_with_me" do
    context "when user is not signed in" do
      include_examples "requires authentication", :shared_with_me_path
    end

    context "when user is signed in" do
      before { sign_in user }

      context "with visible files from other users" do
        it "lists only public files from other users", :aggregate_failures do
          my_file = create_library_file(user: user, name: "Mine.txt")
          owner = create(:user, name: "Alice Owner")
          create_library_file(user: owner, name: "Shared-Doc.pdf")
          private_file = create_library_file(user: create(:user), name: "Private-Doc.pdf")
          private_file.update!(visibility: :private)

          get shared_with_me_path

          expect(response).to have_http_status(:ok)
          expect(response.body).to include("Shared-Doc.pdf")
          expect(response.body).to include("Alice Owner")
          expect(response.body).not_to include(my_file.name)
          expect(response.body).not_to include("Private-Doc.pdf")
        end
      end

      context "when filtering by q" do
        it "returns only matched shared files" do
          create_library_file(user: create(:user), name: "Project Plan.pdf")
          create_library_file(user: create(:user), name: "Holiday.png")

          get shared_with_me_path, params: { q: "project" }

          expect(response.body).to include("Project Plan.pdf")
          expect(response.body).not_to include("Holiday.png")
        end
      end
    end
  end
end
