require 'sinatra/base'
require 'sinatra/multi_route'
require 'doc_my_routes'

module DocMyRoutes::Test
  # App that utilises sinatra/multiroute
  class MultirouteApp < Sinatra::Base
    register Sinatra::MultiRoute

    extend DocMyRoutes::Annotatable

    get '/get_a', '/get_b' do
      'GET A and GET B'
    end

    post '/post_a', '/post_b' do
      'POST A and POST B'
    end

    route :get, :post, ['/get_or_post_a', '/get_or_post_b'] do
      'GET/POST A and GET/POST B'
    end
  end
end
