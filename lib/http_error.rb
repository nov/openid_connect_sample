class HttpError < StandardError
  attr_reader :status
  def initialize(status, message = nil)
    super message
    @status = status
  end

  class BadRequest < HttpError
    def initialize(message = nil)
      super 400, message
    end
  end

  class Unauthorized < HttpError
    def initialize(message = nil)
      super 401, message
    end
  end

  class NotFound < HttpError
    def initialize(message = nil)
      super 404, message
    end
  end
end

