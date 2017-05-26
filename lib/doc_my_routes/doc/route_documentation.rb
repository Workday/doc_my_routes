module DocMyRoutes
  # Class holding documentation information about a given route
  class RouteDocumentation
    attr_accessor :summary, :notes, :status_codes, :examples_regex, :hidden,
                  :produces, :notes_ref
    attr_reader :examples, :parameters

    def initialize
      @status_codes = { 200 => DocMyRoutes::StatusCodeInfo::STATUS_CODES[200] }
      @hidden = false
      @produces = []
      @parameters = {}
    end

    # A route documentation object MUST have a summary, otherwise is not
    # considered documented
    def present?
      !summary.nil?
    end

    def to_hash
      {
        summary: summary,
        notes: notes,
        status_codes: status_codes,
        examples_regex: examples_regex,
        produces: produces,
        examples: examples,
        parameters: parameters,
        hidden: hidden?
      }
    end

    def produces=(values)
      @produces = values.flatten.compact
    end

    def add_parameter(name, options)
      @parameters[name] = options
    end

    def status_codes=(route_status_codes)
      @status_codes = Hash[route_status_codes.map do |code|
        [code, DocMyRoutes::StatusCodeInfo::STATUS_CODES[code]]
      end]
    end

    def examples
      @example ||= begin
        return unless @examples_regex

        examples = ExamplesHandler.routes_examples.values.flatten
        examples = examples.select { |ex| ex['name'] =~ @examples_regex }

        fail ExampleMissing, 'Unable to find examples matching regexp: ' \
                              "#{@examples_regex} for  route '#{summary}'" \
                                if examples.empty?
        examples.flatten
      end
    end

    # Match available examples to the filter for the current route
    def examples_regex=(value)
      @examples_regex = Regexp.new(value)
    end

    def notes
      @notes ||= begin
        return unless @notes_ref

        expanded_path = File.expand_path(@notes_ref)
        fail ScriptError, "Notes file not found: #{@notes_ref}" \
          if @notes_ref.nil? || !File.exist?(expanded_path)

        notes_content = File.read(expanded_path)
        notes_content.gsub(/\n/, ' ')
      end
    end

    def hidden?
      !!@hidden
    end
  end
end
