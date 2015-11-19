# encoding: utf-8

module DocMyRoutes
  # Class that maintain information about the route mapping, as extracted
  # from the actual application
  #
  # Sinatra applications define routes and can be mapped on different
  # namespaces as happens with normal Rack applications.
  #
  # That means that given an application A that provides:
  #   - GET /my_route
  #
  # its actual route might become /my_application/my_route using for instance:
  #
  # Rack::Builder.app do
  #   run Rack::URLMap.new ('my_application' => A)
  # end
  class Mapping
    class << self
      attr_reader :route_mapping

      def extract_mapping(mapping)
        @route_mapping = {}
        mapping.each do |_, location, _, app|
          klass = app.class
          klass = app.instance_variable_get('@instance').class \
            if klass == Sinatra::Wrapper

          (@route_mapping[klass.to_s] ||= []) << location
        end

        assign_namespace
      end

      def mapping_used?
        Object.const_defined?('Rack::URLMap')
      end

      # This method associates to each route its namespace, if detected.
      #
      # Note: when application A is inherited by B and only B is mapped, from
      # the point of view of the mapping only B is defined.
      #
      # Technically speaking, this is absolutely correct because B is the
      # actual application that's registered and used (B provides A's methods).
      #
      # This method duplicates routes for applications that are not mapped in
      # order to list their routes among the ones of the resources that
      # inherit from them
      def assign_namespace
        RouteCollection.routes.each do |class_name, app_routes|
          # TODO: deal with multiple locations for multi mapping
          if route_mapping.include?(class_name)
            app_routes.each do |route|
              route.namespace = @route_mapping[class_name].first
            end
          else
            remap_resource(class_name)
          end
        end
      end

      def remapped_applications
        @remapped_applications ||= Hash.new { |hash, key| hash[key] = [] }
      end

      def remap_resource(class_name)
        DocMyRoutes.logger.debug 'Remapping routes for not mapped ' \
                                 "resource #{class_name}"

        find_child_apps(class_name).each do |child, location|
          DocMyRoutes.logger.debug " - Remapping to #{child}"
          remapped_applications[class_name] << child

          RouteCollection.routes[class_name].each do |route|
            # TODO: If an application has multiple namespaces, we should
            # keep a list of aliases
            route.namespace = location.first
          end
        end
      end

      # Returns the mapped application(s) that inherited from a given class
      def find_child_apps(class_name)
        klass = Object.const_get(class_name)
        route_mapping.select do |mapped_app, _|
          Object.const_get(mapped_app).ancestors.include?(klass)
        end
      end

      def mount_point_for_resource(resource)
        class_name = resource.to_s
        unless route_mapping
          DocMyRoutes.logger.debug 'URLMap not used for resource ' \
                                   "#{class_name}, assuming it's not namespaced"
          return '/'
        end

        # TODO: support multiple application inheriting
        class_name = remapped_applications[class_name].first if \
          remapped_applications.key?(class_name)

        locations = route_mapping[class_name]

        validate_locations(class_name, locations)
      end

      # Detects if multiple locations are available and for now fail
      def validate_locations(resource, locations)
        fail "Resource #{resource} has multiple mappings, but that's not " \
              "supported yet: #{locations}" if locations.size > 1

        return locations.first if locations.size == 1

        DocMyRoutes.logger.debug 'Unable to extract mapping for resource ' \
                                 "#{resource}, it's not mapped! This is not " \
                                 'necessarily a bug and might happen ' \
                                 "because #{resource} is inherited and its " \
                                 'children are mapped.'
        nil
      end
    end
  end
end
