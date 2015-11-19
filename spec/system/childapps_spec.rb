# Encoding: UTF-8

require 'rspec/mocks'
require_relative '../spec_helper.rb'

describe 'Given an application inheriting from MyApp' do
  include Rack::Test::Methods

  before do
    # The tests are only focused on the route created in each context
    # without taking into consideration the real DocMyRoutes routes
    DocMyRoutes::RouteCollection.routes.clear
    reload_app
    reload_app('childapp')
  end

  let(:app_name) { 'DocMyRoutes::Test::MyChildApp' }
  let(:parent_app_name) { 'DocMyRoutes::Test::MyApp' }

  context 'the RouteCollection' do
    subject { DocMyRoutes::RouteCollection.routes }

    it 'tracks correctly its name' do
      expect(subject.keys).to include(app_name)
    end

    it 'tracks correctly its parent' do
      expect(subject.keys).to include('DocMyRoutes::Test::MyApp')
    end
  end

  context 'its routes' do
    subject { DocMyRoutes::RouteCollection.routes[app_name] }

    it 'contain only a POST route' do
      expect(subject.size).to be(1)
      expect(subject.map(&:verb)).to eq(['POST'])
    end

    it 'are not namespaced' do
      expect(subject.map(&:namespace)).to eq([nil])
    end
  end

  context 'using URLMap' do
    before do
      Rack::URLMap.new('/childapp' => Object.const_get(app_name).new)
    end

    context 'the RouteCollection' do
      subject { DocMyRoutes::RouteCollection.routes }

      it 'tracks correctly its name' do
        expect(subject.keys).to include(app_name)
      end

      it 'tracks correctly its parent' do
        expect(subject.keys).to include(parent_app_name)
      end
    end

    context 'its routes' do
      subject { DocMyRoutes::RouteCollection.routes[app_name] }

      it 'are namespaced properly' do
        expect(subject.map(&:namespace)).to eq(['/childapp'])
      end
    end

    context 'its parent\'s routes' do
      subject { DocMyRoutes::RouteCollection.routes[parent_app_name] }

      it 'are namespaced properly' do
        expect(subject.map(&:namespace)).to eq(['/childapp', '/childapp'])
      end
    end
  end

  context 'and another application inheriting from the same MyApp' do
    let(:second_childapp) { 'DocMyRoutes::Test::MySecondChildApp' }

    before do
      reload_app('second_childapp')
    end

    context 'when only one is actually mapped' do
      before do
        klass = Object.const_get(second_childapp)
        Rack::URLMap.new('/second_childapp' => klass.new)
      end

      context 'its routes' do
        subject { DocMyRoutes::RouteCollection.routes[second_childapp] }

        it 'are namespaced properly' do
          expect(subject.map(&:namespace)).to eq(['/second_childapp'])
        end
      end

      context 'its parent\'s routes' do
        subject { DocMyRoutes::RouteCollection.routes[parent_app_name] }

        it 'are namespaced properly' do
          expect(subject.map(&:namespace)).to eq(['/second_childapp',
                                                  '/second_childapp'])
        end
      end
    end

    context 'when both are actually mapped' do
      subject do
        Rack::URLMap.new(
          '/childapp' => Object.const_get(app_name).new,
          '/second_childapp' => Object.const_get(second_childapp).new
        )
      end

      it 'raises an error' do
        expect { subject }.to raise_error(DocMyRoutes::MultipleMappingDetected)
      end
    end
  end
end
