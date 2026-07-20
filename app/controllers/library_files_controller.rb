# "My Library" list — UI mock (Step 4, first part). Hardcoded rows only: no DB
# query yet, and no search/sort/pagination (those land in the next part). Inherits
# AuthController so the page requires a signed-in user, which makes Log out meaningful.
class LibraryFilesController < AuthController
  # Minimal row shape for the mock; mirrors the real LibraryFile fields we'll bind
  # to later (name, modified date, human-readable size, private flag).
  MockFile = Struct.new(:name, :modified, :size, :is_private, keyword_init: true)

  MOCK_FILES = [
    MockFile.new(name: "Q3 Roadmap.pdf",       modified: "Jul 12, 2026", size: "2.4 MB",  is_private: false),
    MockFile.new(name: "Design Tokens.sketch", modified: "Jul 9, 2026",  size: "18.7 MB", is_private: true),
    MockFile.new(name: "Team Photo.jpg",       modified: "Jul 5, 2026",  size: "3.1 MB",  is_private: false),
    MockFile.new(name: "Meeting Notes.txt",    modified: "Jul 2, 2026",  size: "12 KB",   is_private: false),
    MockFile.new(name: "Budget.xlsx",          modified: "Jun 28, 2026", size: "486 KB",  is_private: false),
    MockFile.new(name: "Contract - Draft.docx", modified: "Jun 24, 2026", size: "94 KB",  is_private: false),
    MockFile.new(name: "Logo Assets.zip",      modified: "Jun 20, 2026", size: "27.9 MB", is_private: false)
  ].freeze

  def index
    @files = MOCK_FILES
  end
end
