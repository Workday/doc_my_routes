require 'doc_my_routes/version'
require 'doc_my_routes/doc/errors'
require 'doc_my_routes/doc/documentation'
require 'doc_my_routes/doc/config'
require 'doc_my_routes/doc/mixins/annotatable'

# General module that defines the base access to DocMyRoutes
module DocMyRoutes
  class << self
    # Expose logging hook
    attr_writer :logger
    attr_accessor :config

    def logger
      @logger ||= begin
        require 'logger'
        Logger.new($stdout).tap do |log|
          log.progname = name
        end
      end
    end
  end
end
