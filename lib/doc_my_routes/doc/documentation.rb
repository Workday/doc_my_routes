require_relative 'status_code_info'
require_relative 'examples_handler'
require_relative '../version'
require 'ostruct'

module DocMyRoutes
  # class which contains the main functions to generate documentation
  class Documentation
    attr_reader :routes

    def self.generate
      Documentation.new(RouteCollection.routes, DocMyRoutes.config).generate
    end

    def initialize(routes, config)
      @routes = routes
      @config = config
    end

    def generate
      generate_content
      generate_output
      copy_css_files
    end

    private

    def resource_name(resource)
      resource.to_s.split('::').last.downcase
    end

    def generate_content
      routes.each do |resource, rts|
        content[:main][:apis][resource_name(resource)] = rts.map(&:to_hash)
      end
    end

    def copy_css_files
      FileUtils.cp_r(@config.css_file_path,
                     @config.destination_dir)
    end

    def content
      # Set the content initial structure and default values
      @content ||= {
        main: {
          apiVersion: VERSION,
          info: {
            title: @config.title,
            description: @config.description
          },
          apis: {}
        }
      }
    end

    def generate_output
      case @config.format
      when :html
        generate_html
      when :partial_html
        generate_partial_html
      end
    end

    def partial_html
      partial_binding = OpenStruct.new(data: content)
                              .instance_eval { binding }
      index_file = @config.index_file

      template_file = File.read(@config.partial_template_file)
      ERB.new(template_file, 0, '<>').result(partial_binding)
    end

    def generate_partial_html
      index_file = @config.index_file

      File.open(index_file, 'w') do |f|
        f.write partial_html
      end
      DocMyRoutes.logger.info "Generated Partial HTML file to #{index_file}"
    end

    def generate_html
      index_file = @config.index_file
      html_binding = OpenStruct.new(body: partial_html, title: content[:main][:info][:title])
                              .instance_eval { binding }

      File.open(index_file, 'w') do |f|
        template_file = File.read(@config.index_template_file)
        content = ERB.new(template_file, 0, '<>').result(html_binding)
        f.write content
      end
      DocMyRoutes.logger.info "Generated HTML file to #{index_file}"
    end
  end
end
