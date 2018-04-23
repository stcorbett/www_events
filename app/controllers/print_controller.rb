class PrintController < ApplicationController

  def show
    @events = Event.configured_year.sorted_by_date
  end

end
