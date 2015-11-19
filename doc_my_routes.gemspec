# coding: utf-8
lib = File.expand_path(File.join('..', 'lib'), __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'doc_my_routes/version'

Gem::Specification.new do |spec|
  spec.name          = 'doc_my_routes'
  spec.version       = DocMyRoutes::VERSION
  spec.authors       = ['Workday, Ltd.']
  spec.email         = ['prd.eng.os@workday.com']

  spec.summary       = 'A simple gem to document Sinatra routes'
  spec.description   = 'DocMyRoutes provides a way to annotate Sinatra ' \
                       'routes and generate documentation'
  spec.homepage      = 'https://github.com/Workday/doc_my_routes'
  spec.licenses      = ['MIT']

  spec.files         = Dir['lib/**/*.rb', 'etc/css/base.css',
                           'etc/index.html.erb']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '>= 3.0.0'
  spec.add_development_dependency 'rack-test', '>= 0.6.2'
  spec.add_development_dependency 'rubocop', '>= 0.16'
  spec.add_development_dependency 'sinatra'
end
