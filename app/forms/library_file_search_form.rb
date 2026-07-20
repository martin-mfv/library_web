class LibraryFileSearchForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  SORT_COLUMNS = {
    "name" => "library_files.name",
    "size" => "active_storage_blobs.byte_size",
    "date" => "active_storage_blobs.created_at"
  }.freeze

  ASC_DIRECTION = "asc"
  DESC_DIRECTION = "desc"

  attribute :q, :string
  attribute :sort, :string, default: "date"
  attribute :direction, :string, default: "desc"

  def initialize(relation, url, attributes = {})
    @relation = relation
    @url = url
    super(attributes)
  end

  def url
    @url
  end

  def method
    :get
  end

  def sorted_by?(column)
    sort == column.to_s
  end

  def direction_for(column)
    sorted_by?(column) && direction == ASC_DIRECTION ? DESC_DIRECTION : ASC_DIRECTION
  end

  def search!
    scope = @relation.with_attached_attachment.includes(:user)
    order_scope(filter_scope(scope))
  end

  private

  def filter_scope(scope)
    scope.search_by_name(q)
  end

  def order_scope(scope)
    column = SORT_COLUMNS.fetch(sort)
    scope = scope.joins(:attachment_blob)
    scope.order(Arel.sql("#{column} #{direction}")).order("library_files.id" => :asc)
  end
end
