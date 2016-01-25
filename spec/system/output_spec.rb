require_relative '../spec_helper.rb'
require 'nokogiri'

describe DocMyRoutes do
  before do
    # The tests are only focused on the route created in each context
    # without taking into consideration the real DocMyRoutes routes
    DocMyRoutes::RouteCollection.routes.clear
  end

  context 'with summary, notes and status codes for a GET verb' do
    let (:tmp_dir) { Dir.mktmpdir }
    after { FileUtils.remove_entry tmp_dir }

    before do
      DocMyRoutes.configure do |c|
        c.destination_dir = tmp_dir
      end
    end

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

    context 'when I run the generation' do
      subject do
        DocMyRoutes::Documentation.generate
        Nokogiri::XML(File.open("#{tmp_dir}/#{output_file}.html"))
      end

      context 'using the default formatter' do
        let(:output_file) { 'index' }

        it 'generates a valid HTML file' do
          expect(subject.children.size).to eq 2
          expect(subject.children[1].name).to eq('html')
        end
      end

      context 'using the :partial_html formatter' do
        let(:output_file) { 'index_partial' }

        before do
          DocMyRoutes.configure do |c|
            c.format = :partial_html
            c.destination_dir = tmp_dir
          end
        end

        it 'generates a valid HTML file' do
          expect(subject.children.size).to eq 1
          expect(subject.children.first.name).to eq('section')
        end
      end
    end
  end
end
