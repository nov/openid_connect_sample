class HttpError < StandardError
  attr_reader :status
  def initialize(status, message = nil)
    super message
    @status = status
  end

  class NotFound < HttpError
    def initialize(message = nil)
      super 404, message
    end
  end
end

