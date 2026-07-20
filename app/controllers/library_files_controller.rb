class LibraryFilesController < AuthController
  before_action :set_visible_library_file, only: [ :copy ]
  before_action :set_owned_library_file, only: [ :destroy, :change_visibility ]

  def index
    @search = LibraryFileSearchForm.new(current_user.library_files, { action: :index }, search_params)
    @files = @search.search!.page(params[:page])
  end

  def shared_with_me
    relation = LibraryFile.visibility_public.where.not(user_id: current_user.id)
    @search = LibraryFileSearchForm.new(relation, { action: :shared_with_me }, search_params)
    @files = @search.search!.page(params[:page])

    render :index
  end

  def copy
    copy = current_user.library_files.new(
      name: copied_name(@library_file.name),
      visibility: :private,
      copied_from: @library_file
    )

    copy.attachment.attach(
      io: StringIO.new(@library_file.attachment.download),
      filename: @library_file.attachment.filename.to_s,
      content_type: @library_file.attachment.content_type
    )

    if copy.save
      redirect_to root_path(sort: "date", direction: "desc"), notice: "File copied successfully."
    else
      redirect_to root_path(sort: "date", direction: "desc"), alert: "Unable to copy file."
    end
  end

  def destroy
    if @library_file.destroy
      redirect_back fallback_location: root_path, notice: "File deleted successfully."
    else
      redirect_back fallback_location: root_path, alert: "Unable to delete file."
    end
  end

  def change_visibility
    next_visibility = @library_file.visibility_public? ? :private : :public

    if @library_file.update(visibility: next_visibility)
      redirect_back fallback_location: root_path, notice: "Visibility updated successfully."
    else
      redirect_back fallback_location: root_path, alert: "Unable to update visibility."
    end
  end

  private

  def set_visible_library_file
    @library_file = LibraryFile.visibility_public.or(current_user.library_files).find(params[:id])
  end

  def set_owned_library_file
    @library_file = current_user.library_files.find(params[:id])
  end

  def copied_name(name)
    "#{name} (copy)"
  end

  def search_params
    params.permit(:q, :sort, :direction).to_h
  end
end
