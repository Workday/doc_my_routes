# encoding: utf-8
require_relative 'route'
require_relative 'documentation'

module DocMyRoutes
  # Simple object representing all the sinatra routes
  class RouteCollection
    class << self
      def routes
        @routes ||= {}
      end

      def <<(route)
        (routes[route.resource.to_s] ||= []) << route
      end

      def log_routes
        routes.sort_by { |name, _| name }.each do |app_name, app_routes|
          # TODO: move namespace on app?
          namespace = format('%-50s', app_routes.first.namespace)
          DocMyRoutes.logger.debug "Adding route to #{namespace} - #{app_name}"

          app_routes.each { |rte| DocMyRoutes.logger.debug " - #{rte}" }
        end
      end
    end
  end
end
