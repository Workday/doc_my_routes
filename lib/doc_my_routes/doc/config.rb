# Expose config hook
module DocMyRoutes
  class << self
    attr_accessor :config

    # Nothing fancy here, just gem configuration inspired by many gems
    # e.g., https://robots.thoughtbot.com/mygem-configure-block
    def configure
      self.config ||= Config.new
      yield(config)
    end

    # Inner class to maintain configuration settings
    class Config
      attr_accessor :title, # Project title
                    :description, # Project description
                    :destination_dir, # Where to store the documentation
                    :css_file_path, # Path to look for a CSS file
                    :examples_path_regexp # Path regexp to example files
      attr_reader :index_template_file # Template used for the index.html

      def initialize
        @title = @description = @examples_path_regexp = nil

        @destination_dir = File.join(Dir.pwd, 'doc', 'api')

        default_static_path = File.join(File.dirname(__FILE__), '..', '..',
                                        '..', 'etc')
        @css_file_path = File.join(default_static_path, 'css', 'base.css')
        @index_template_file = File.join(default_static_path, 'index.html.erb')
      end

      def examples
        @examples_path_regexp.nil? ? [] : Dir.glob(@examples_path_regexp)
      end

      # Calculate the relative path of the CSS used
      def destination_css
        # TODO: make it more robust
        File.basename(@css_file_path)
      end

      def index_file
        File.join(@destination_dir, 'index.html')
      end
    end
  end
end
