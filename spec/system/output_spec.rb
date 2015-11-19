require_relative '../spec_helper.rb'

describe DocMyRoutes do
  before do
    # The tests are only focused on the route created in each context
    # without taking into consideration the real DocMyRoutes routes
    DocMyRoutes::RouteCollection.routes.clear
  end

  context 'with summary, notes and status codes for a GET verb' do
    def doc_route
      # Test class with only two routes GET and HEAD
      self.class.const_set :DocRoute, Class.new(DocMyRoutes::Test::MyApp) {
        summary 'My example route'
        notes 'Example route'
        status_codes [200]
        get '/api/example' do
        end
      }
    end

    it 'generates a valid HTML file' do
      pending 'Validate output'
      fail
      # doc_route
      # TODO: validate output
      # DocMyRoutes::Documentation.generate
    end
  end
end
