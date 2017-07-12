require 'sinatra/base'
require 'sinatra/namespace'
require 'doc_my_routes'

module DocMyRoutes::Test
  # App with nested namespaces that uses DocMyRoutes
  class NamespaceApp < Sinatra::Base
    register Sinatra::Namespace

    extend DocMyRoutes::Annotatable

    DocMyRoutes.configure do |config|
      config.title = 'Test application'
      config.description = 'Example application to test DocMyRoutes'
    end

    namespace '/path_a' do
      namespace '/subpath_1' do
        summary 'Example GET'
        notes 'Creates an example GET route that returns hello'
        status_codes [200]
        get '/sample_get' do
          [200, {}, ['Hello from GET!']]
        end
      end

      namespace '/subpath_2' do
        summary 'Example POST'
        notes 'Creates an example POST route that returns hello'
        status_codes [200]
        post '/sample_post' do
          [200, {}, ['Hello from POST!']]
        end
      end
    end
  end
end
