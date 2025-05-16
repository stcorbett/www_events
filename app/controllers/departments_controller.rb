class DepartmentsController < ApplicationController
  def index
    respond_to do |format|
      format.html { redirect_to(root_path) }
      format.json do
        sql = PgJbuilder.render_object 'departments/index'
        render json: ActiveRecord::Base.connection.select_value(sql)
      end
    end
  end
end
