class UploadsController < AuthController
  def new
  end

  def create
    @library_file = current_user.library_files.new(
      name: create_params[:name],
      visibility: create_params[:visibility] || :public
    )
    signed_id = create_params[:signed_id]
    @library_file.attachment.attach(signed_id) if signed_id.present?

    if @library_file.save
      render json: { id: @library_file.id, name: @library_file.name }, status: :created
    else
      render json: { errors: @library_file.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def create_params
    params.require(:library_file).permit(:name, :signed_id, :visibility)
  end
end
