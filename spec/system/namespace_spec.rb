# Encoding: UTF-8

require 'rspec/mocks'
require_relative '../spec_helper.rb'

describe 'Given an application with nested namespaces' do
  include Rack::Test::Methods

  before do
    # The tests are only focused on the route created in each context
    # without taking into consideration the real DocMyRoutes routes
    DocMyRoutes::RouteCollection.routes.clear
    reload_app('namespaceapp')
  end

  let(:app_name) { 'DocMyRoutes::Test::NamespaceApp' }

  context 'its routes' do
    subject { DocMyRoutes::RouteCollection.routes[app_name] }

    it 'contain only a GET and a POST route' do
      expect(subject.size).to be(2)
      expect(subject.map(&:verb)).to eq(['GET', 'POST'])
    end

    it 'have correct route patterns' do
      expect(subject.map(&:route_pattern)).to eq(['/path_a/subpath_1/sample_get', '/path_a/subpath_2/sample_post'])
    end

    it 'are not namespaced' do
      # Namespaces are currently used for Sinatra Child Apps only
      expect(subject.map(&:namespace)).to eq([nil, nil])
    end
  end
end
