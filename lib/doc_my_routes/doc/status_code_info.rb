# encoding: UTF-8

module DocMyRoutes
  # Mapping from HTTP status codes to human readable description
  module StatusCodeInfo
    STATUS_CODES = {
      200 => 'OK',
      201 => 'Created',
      202 => 'Accepted',
      204 => 'No Content',
      303 => 'See Other',
      304 => 'Not modified',
      400 => 'Bad Request',
      401 => 'Unauthorized',
      403 => 'Forbidden',
      404 => 'Not Found',
      410 => 'Gone',
      409 => 'Conflict',
      500 => 'Internal Server Error',
      503 => 'Service Unavailable'
    }
  end
end
