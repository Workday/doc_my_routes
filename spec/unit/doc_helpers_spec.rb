# Encoding: UTF-8

require 'rspec/mocks'
require_relative '../spec_helper.rb'
require_relative '../support/myapp'

describe 'Route documentation' do
  include Rack::Test::Methods

  DEFAULT_SUMMARY = 'Example summary'
  DEFAULT_NOTES = 'Example notes'
  DEFAULT_NOTES_FILE = 'etc/example_notes.txt'
  DEFAULT_STATUS_CODES = [200, 401]
  DEFAULT_PARAMETER_OPTIONS = { type: :integer, description: 'example parameter' }

  def mock_notes_file(content, path = 'notes.txt')
    mock_notes_path = File.expand_path(path)
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with(mock_notes_path).and_return(true)
    allow(File).to receive(:read).and_call_original
    allow(File).to receive(:read).with(mock_notes_path).and_return(content)
  end

  let(:default_docs) do
    doc = DocMyRoutes::RouteDocumentation.new
    doc.summary = DEFAULT_SUMMARY
    doc.notes = DEFAULT_NOTES
    doc.status_codes = DEFAULT_STATUS_CODES
    doc.add_parameter(:example_id, DEFAULT_PARAMETER_OPTIONS)
    doc
  end

  RSpec::Matchers.define :match_documentation do |expected|
    match do |actual|
      expect(actual).to respond_to(:documentation),
                        "Actual object #{actual} doesn't have documentation"

      actual_docs = actual.documentation
      actual_docs.to_hash == expected.to_hash
    end
    description { "The route #{actual} doesn't match #{expected}" }
  end

  RSpec.shared_examples 'a correctly tracked route' do
    subject do
      key = DocMyRoutes::RouteCollection.routes.keys[0]
      DocMyRoutes::RouteCollection.routes[key]
    end

    it 'contains a valid route' do
      doc_route
      # Due to the 'before' section I know there is only one class
      # in the routes Hash

      expect(subject.size).to eq(1)
      expect(subject.first).to match_documentation(default_docs)
    end
  end

  before do
    # The tests are only focused on the route created in each context
    # without taking into consideration the real DocMyRoutes routes
    DocMyRoutes::RouteCollection.routes.clear
  end

  context 'with summary, notes, parameter and status codes for a GET verb' do
    subject do
      key = DocMyRoutes::RouteCollection.routes.keys[0]
      DocMyRoutes::RouteCollection.routes[key]
    end

    def doc_route
      # Test class with only two routes GET and HEAD
      self.class.const_set :DocRoute, Class.new(DocMyRoutes::Test::MyApp) {
        summary DEFAULT_SUMMARY
        notes DEFAULT_NOTES
        status_codes DEFAULT_STATUS_CODES
        parameter :example_id, DEFAULT_PARAMETER_OPTIONS
        get '/api/example' do
        end
      }
    end

    it_behaves_like 'a correctly tracked route'
  end

  context 'with a summary, notes in an external file, parameter and status codes' do
    def doc_route
      mock_notes_file(DEFAULT_NOTES, DEFAULT_NOTES_FILE)
      # Test class with only two routes GET and HEAD
      self.class.const_set :DocRoute, Class.new(DocMyRoutes::Test::MyApp) {
        summary DEFAULT_SUMMARY
        notes_ref DEFAULT_NOTES_FILE
        status_codes DEFAULT_STATUS_CODES
        parameter :example_id, DEFAULT_PARAMETER_OPTIONS
        post '/api/example_notes_file' do
        end
      }
    end

    it_behaves_like 'a correctly tracked route'
  end
end
