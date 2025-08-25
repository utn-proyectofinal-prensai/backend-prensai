# frozen_string_literal: true

class ServiceResult
  attr_reader :payload, :error

  def initialize(success:, payload: nil, error: nil)
    @success = success
    @payload = payload
    @error = error
  end

  def success?
    @success
  end

  def failure?
    !@success
  end
end
