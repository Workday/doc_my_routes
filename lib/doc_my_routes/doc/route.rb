# encoding: utf-8

require 'forwardable'

module DocMyRoutes
  # Simple object representing a route
  class Route
    extend Forwardable

    attr_accessor :resource, :verb, :route_pattern, :conditions
    attr_reader :namespace, :documentation

    def_delegators :documentation, :has_docs?

    def initialize(resource, verb, route_pattern, conditions, documentation)
      @resource = resource
      @verb = verb
      @route_pattern = route_pattern
      # TODO: We could inherit this from the application mapping
      @namespace = nil
      @conditions = conditions
      @documentation = documentation
    end

    def to_hash
      {
        http_method: verb,
        parameters: param_info,
        path: path
      }.merge(documentation.to_hash)
    end

    def path
      @path ||= begin
        path = Mapping.mount_point_for_resource(resource) + route_pattern
        # Changing double slashes into single slash
        # Removing the trailing ?
        # Removing the trailing / only if it's not the only character
        # FROM /api/nodes/:id/?      TO      /api/nodes/:id
        # Change the path variable from Ruby style into brackets style
        # from /api/nodes/:id/       TO       /api/nodes/{id}/
        path.gsub(%r{//}, '/')
            .gsub(/(\?+)*$/, '')
            .gsub(%r{(.+)\/$}, '\\1')
            .gsub(/:(?<path_var>\w+)/, '{\k<path_var>}')
      end
    end

    def namespace=(value)
      fail MultipleMappingDetected, "Multiple namespaces detected for #{self}"\
          'and not supported yet' if namespace && value != namespace
      @namespace = value
    end

    def to_s
      "#{verb} #{namespace}#{route_pattern} #{conditions}"
    end

    # Return a list of parameters required by this route, if specified.
    #
    # Try to extract parameters from the route definition otherwise
    def param_info
      if conditions[:parameters]
        conditions[:parameters]
      else
        route_pattern.split('/').map do |part|
          part.start_with?(':') ? part[1..-1].to_sym : nil
        end.compact
      end
    end
  end
end
