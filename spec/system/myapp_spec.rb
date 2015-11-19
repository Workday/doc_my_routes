# Encoding: UTF-8

require 'rspec/mocks'
require_relative '../spec_helper.rb'

describe 'Given a simple application' do
  include Rack::Test::Methods

  before do
    # The tests are only focused on the route created in each context
    # without taking into consideration the real DocMyRoutes routes
    DocMyRoutes::RouteCollection.routes.clear
    reload_app
  end

  let(:app_name) { 'DocMyRoutes::Test::MyApp' }

  context 'the RouteCollection' do
    subject { DocMyRoutes::RouteCollection.routes }

    it 'tracks correctly its name' do
      expect(subject.keys).to eq([app_name])
    end
  end

  context 'its routes' do
    subject { DocMyRoutes::RouteCollection.routes[app_name] }

    it 'are two routes GET and HEAD' do
      expect(subject.size).to be(2)
      expect(subject.map(&:verb)).to eq(%w(GET HEAD))
    end

    it 'are not namespaced' do
      expect(subject.map(&:namespace)).to eq([nil, nil])
    end
  end

  context 'using URLMap' do
    before do
      Rack::URLMap.new('/myapp' => Object.const_get(app_name).new)
    end

    context 'the RouteCollection' do
      subject { DocMyRoutes::RouteCollection.routes }

      it 'tracks correctly its name' do
        expect(subject.keys).to include(app_name)
      end
    end

    context 'its routes' do
      subject { DocMyRoutes::RouteCollection.routes[app_name] }

      it 'are correctly namespaced' do
        expect(subject.map(&:namespace)).to eq(['/myapp', '/myapp'])
      end
    end
  end
end
