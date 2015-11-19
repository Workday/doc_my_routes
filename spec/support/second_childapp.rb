require_relative 'myapp'

module DocMyRoutes::Test
  # Example app that uses inherits from MyApp
  class MySecondChildApp < MyApp
    summary 'Example other route'
    notes 'Creates an example route that returns hello'
    status_codes [202]
    delete '/' do
      [202, {}, ['Hello from DELETE!']]
    end
  end
end
