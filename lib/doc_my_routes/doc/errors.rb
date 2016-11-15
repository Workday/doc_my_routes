# Define error classes
module DocMyRoutes
  class ExampleMissing < StandardError; end
  class UnsupportedError < StandardError; end
  class MultipleMappingDetected < UnsupportedError; end
  class NoMappingDetected < UnsupportedError; end
end
