class ErrorsController < ActionController::API
  # This controller handles not found routes and does not require CSRF protection
  # as it is intended to return clean 404 responses for API requests

  def routing_error
    head :not_found
  end
end
