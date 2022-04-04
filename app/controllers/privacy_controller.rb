class PrivacyController < ApplicationController
  skip_before_filter :require_login, :only => :show

  def show; end

end
