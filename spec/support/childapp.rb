require_relative 'myapp'

module DocMyRoutes::Test
  # Example app that uses inherits from MyApp
  class MyChildApp < MyApp
    summary 'Example post'
    notes 'Creates an example POST route that returns hello'
    status_codes [200]
    post '/' do
      [200, {}, ['Hello from POST!']]
    end
  end
end
