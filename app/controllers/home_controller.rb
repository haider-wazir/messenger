class HomeController < ApplicationController
  skip_before_action :authorize_request
  
  def index
  end
end
