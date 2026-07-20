class LibraryFilesController < AuthController
  def index
    @search = LibraryFileSearchForm.new(current_user.library_files, { action: :index }, search_params)
    @files = @search.search!.page(params[:page])
  end

  def shared_with_me
    relation = LibraryFile.visible_to(current_user).where.not(user_id: current_user.id)
    @search = LibraryFileSearchForm.new(relation, { action: :shared_with_me }, search_params)
    @files = @search.search!.page(params[:page])

    render :index
  end

  private

  def search_params
    params.permit(:q, :sort, :direction).to_h
  end
end
