# frozen_string_literal: true

class ServiceResult
  attr_reader :payload, :errors

  def initialize(success:, payload: nil, errors: nil)
    @success = success
    @payload = payload
    @errors = errors
  end

  def success?
    @success
  end

  def failure?
    !@success
  end
end
