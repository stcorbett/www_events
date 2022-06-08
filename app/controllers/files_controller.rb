class FilesController < ApplicationController
  def show
    file_name = params[:name]
    file_name += ".#{params[:format]}" if params[:format].present?

    @file = HostedFile.find_by(name: file_name)
    raise ActiveRecord::RecordNotFound unless @file

    render json: @file.content, content_type: 'application/json'
  end
end
