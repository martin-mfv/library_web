class CreateLibraryFiles < ActiveRecord::Migration[7.2]
  def change
    create_table :library_files do |t|
      t.string :name, null: false
      # Integer-backed enum (see LibraryFile#visibility): 0 = private (owner only),
      # 1 = public (shared). Integer chosen over a boolean so new levels
      # (e.g. shared-via-link, team) can be added without another migration.
      t.integer :visibility, null: false, default: 1
      t.references :user, null: false, foreign_key: true
      t.references :copied_from, null: true,
                                 foreign_key: { to_table: :library_files }

      t.timestamps
    end
  end
end
