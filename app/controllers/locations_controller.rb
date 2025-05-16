class LocationsController < ApplicationController
  skip_before_action :require_login, only: :index

  def index
    respond_to do |format|
      format.html { redirect_to(root_path) }
      format.json do
        sql = PgJbuilder.render_object 'locations/index'
        render json: ActiveRecord::Base.connection.select_value(sql)
      end
    end
  end
end
