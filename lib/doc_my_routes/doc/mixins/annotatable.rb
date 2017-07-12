# Encoding: UTF-8

require_relative '../route_collection'
require_relative '../route_documentation'
require_relative '../mapping'

module DocMyRoutes
  # Logic to help with the REST API documentation.
  # This module provides methods to "decorate" sinatra routes as follows:
  #   summary 'Short definition of the route'
  #   notes 'More detailed explanation of the operation'
  #   status_codes [200, 401, 500]
  #   get '/api/example' do
  #   end
  module Annotatable
    class << self
      # When a class is extended with this module documentation specific
      # features are enabled
      def extended(mod)
        # Wrap sinatra's route method to register the defined routes
        mod.define_singleton_method(:route) do |*args, &block|
          result = super(*args, &block)
          
          options = args.last.is_a?(Hash) ? args.pop : {}
          routes = [*args.pop].map(&:to_s) # ensure routes are strings
          verbs = args.map { |verb| verb.is_a?(Symbol) ? verb.to_s.upcase : verb }
          
          verbs.each do |verb|
            routes.each do |route_pattern|
              reset_doc = verb.equal?(verbs.last) && route_pattern.equal?(routes.last)

              track_route(self, verb, route_pattern, options, reset_doc, &block)
            end
          end

          result
        end

        extract_url_map if Mapping.mapping_used?
      end

      private

      # Wrap Rack::URLMap to extract the actual mapping when URLMap is used
      def extract_url_map
        DocMyRoutes.logger.debug 'Wrapping Rack::URLMap to extract mapping'

        Rack::URLMap.send(:define_method, :initialize) do |map = {}|
          mapping = remap(map)

          fail 'Used Rack::URLMap, but unable to get a mapping' unless mapping

          # Extract mapping for every class
          #
          # Note that the same app could be mapped to different endpoints,
          # that's why the mapping is instance -> [location...]
          DocMyRoutes::Mapping.extract_mapping(mapping)

          mapping
        end
      end
    end

    def route_documentation
      @route_documentation ||= begin
        RouteDocumentation.new
      end
    end

    def no_doc
      route_documentation.hidden = true
    end

    def produces(*value)
      route_documentation.produces = value
    end

    def summary(value)
      route_documentation.summary = value
    end

    def notes(value)
      route_documentation.notes = value
    end

    def status_codes(value)
      route_documentation.status_codes = value
    end

    # Match interaction examples to this route
    def examples_regex(value)
      route_documentation.examples_regex = value
    end

    # It's possible to provide the route notes using a file to avoid adding
    # too much text in the route definition
    def notes_ref(value)
      route_documentation.notes_ref = value
    end

    def parameter(value, options = {})
      route_documentation.add_parameter(value, options)
    end

    private

    def track_route(resource, verb, route_pattern, conditions, reset_doc)
      unless route_documentation.hidden? || skip_route(verb)
        route = Route.new(resource, verb, route_pattern, conditions,
                          route_documentation)

        DocMyRoutes::RouteCollection << route
      end

      # Ensure values are reset
      reset_doc_values if reset_doc
    end

    # The summary, notes and status codes are only valid for one route
    # therefore they should be reset before the next route is processed
    def reset_doc_values
      @route_documentation = nil
      @skip_route = false
    end

    # Sinatra duplicates the GET route creating an extra HEAD route
    # The HEAD route is often not decorated with summary, notes and status code
    # so this method gets those values from the previously defined GET route
    def skip_route(verb)
      verb == 'HEAD' && !route_documentation.present?
    end
  end
end
