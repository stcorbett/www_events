class ApisController < ApplicationController
  before_action :require_admin
  
  def index
    # For now, just display links to available APIs
  end
end
