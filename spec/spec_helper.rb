$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'doc_my_routes'

require 'logger'
logger = Logger.new(STDOUT)
logger.level = Logger::WARN
DocMyRoutes.logger = logger

require 'rack/test'

# Ensure the example application is reloaded and hooks are re-invoked
def reload_app(name = 'myapp')
  load File.join(File.dirname(__FILE__), 'support', "#{name}.rb")
end
