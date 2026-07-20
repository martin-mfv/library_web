class LibraryFile < ApplicationRecord
  belongs_to :user
  belongs_to :copied_from, class_name: self.name, optional: true

  has_many :copies, class_name: self.name, foreign_key: :copied_from_id, dependent: :nullify

  has_one_attached :attachment

  enum :visibility, { private: 0, public: 1 }, default: :public, prefix: :visibility

  scope :search_by_name, lambda { |query|
    return all if query.blank?

    where("library_files.name ILIKE ?", "%#{sanitize_sql_like(query)}%")
  }

  validates :name, presence: true, length: { maximum: 255 }
  validate :attachment_must_be_present

  def byte_size
    attachment.blob&.byte_size
  end

  def uploaded_at
    attachment.blob&.created_at
  end

  def content_type
    attachment.blob&.content_type
  end

  private

  def attachment_must_be_present
    errors.add(:attachment, :blank) unless attachment.attached?
  end
end
