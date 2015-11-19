require 'sinatra/base'
require 'doc_my_routes'

module DocMyRoutes::Test
  # Example app that uses DocMyRoutes
  class MyApp < Sinatra::Base
    extend DocMyRoutes::Annotatable

    DocMyRoutes.configure do |config|
      config.title = 'Test application'
      config.description = 'Example application to test DocMyRoutes'
    end

    summary 'Example get'
    notes 'Creates an example GET route that returns hello'
    status_codes [200]
    get '/' do
      [200, {}, ['Hello!']]
    end

    summary 'Example head'
    notes 'Explicit HEAD to verify that we do not collapse it'
    status_codes [200]
    head '/' do
      [200, {}, ['Hello HEAD!']]
    end
  end
end
