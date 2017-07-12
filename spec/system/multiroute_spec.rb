# Encoding: UTF-8

require 'rspec/mocks'
require_relative '../spec_helper.rb'

describe 'Given an application utilising sinatra/multi_route' do
  include Rack::Test::Methods

  before do
    # The tests are only focused on the route created in each context
    # without taking into consideration the real DocMyRoutes routes
    DocMyRoutes::RouteCollection.routes.clear
    reload_app('multirouteapp')
  end

  let(:app_name) { 'DocMyRoutes::Test::MultirouteApp' }

  context 'its routes' do
    subject { DocMyRoutes::RouteCollection.routes[app_name] }

    it 'contain all specified verbs' do
      expect(subject.size).to be(8)
      expect(subject.map(&:verb)).to eq(
        %w[GET GET POST POST GET GET POST POST]
      )
    end

    it 'have correct route patterns' do
      expect(subject.map(&:route_pattern)).to eq(
        ['/get_a',
         '/get_b',
         '/post_a',
         '/post_b',
         '/get_or_post_a',
         '/get_or_post_b',
         '/get_or_post_a',
         '/get_or_post_b']
      )
    end

    it 'are not namespaced' do
      # Namespaces are currently used for Sinatra Child Apps only
      expect(subject.map(&:namespace)).to eq(Array.new(8, nil))
    end
  end
end
