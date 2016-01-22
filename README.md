# DocMyRoutes

[![Build Status](https://travis-ci.org/Workday/doc_my_routes.svg)](https://travis-ci.org/Workday/doc_my_routes)
[![Gem Version](https://badge.fury.io/rb/doc_my_routes.svg)](https://badge.fury.io/rb/doc_my_routes)

This gem provides helpers to annotate Sinatra routes and automatically generate HTML API documentation.

Routes can be annotated with information such as:
* summary (short description)
* notes (extended description)
* content type produced
* returning status codes

In addition, examples can be linked to routes and automatically associated.
See the section "Associating examples" for more information.

## Installation

DocMyRoutes can be installed via Rubygems or compiling and installing it yourself as:

```
$ gem build doc_my_routes.gemspec
$ gem install doc_my_routes-VERSION.gem
```

## Usage

Using DocMyRoutes is quite straight-forward and it basically requires two steps:
* configure DocMyRoutes and annotate your application
* triggering the generation of the documentation

### Configuring DocMyRoutes and annotating routes

First of all, DocMyRoutes needs to be configured with your project title
and description (see the *Customisation* section for other options).

Simply ```require 'doc_my_routes'``` and set the two options:

```ruby
DocMyRoutes.configure do |config|
  config.title = "My Application"
  config.description = "My Application description"
end
```

then ```extend DocMyRoutes::Annotatable```
in your Sinatra application and start annotating your routes.

Example:
```ruby
require 'sinatra/base'
require 'doc_my_routes'

DocMyRoutes.configure do |config|
  config.title = "My Application"
  config.description = "My Application description"
end

class MyApp < Sinatra::Base
  # Add support for documenting routes
  extend DocMyRoutes::Annotatable

  summary 'Example route'
  notes 'Simple route that gets an ID and returns a string'
  produces 'text/plain'
  status_codes [200]
  get '/:id' do |id|
    "Received #{id}"
  end
end
```

### Generating documentation

In your *config.ru* (or in your main .rb file) you can trigger the generation
of the documentation invoking ```DocMyRoutes::Documentation.generate```.

Example:
```ruby
require_relative 'my_app'

# Configure your app here...

...
# If documentation requested (e.g., using an input flag)
DocMyRoutes::Documentation.generate
...
```

This will generate HTML API documentation to the configured ```destination_dir```. By default the destination directory is ```doc/api```.

### Associating examples

In addition to the helpers described above, DocMyRoutes provides a
```examples_regex``` helper that will automatically link call examples to the
documentation of that route.

An example represents a request/response interaction related to that route and
it's application specific. DocMyRoutes provides a structure to automatically
link them to a given route.

Examples must follow a specific format, in order to be correctly used.

1. Must be in YAML format
1. Must have a *name* key associated, used to filter examples
1. Must have an *action* key, that defines the action of that route (i.e., GET /myroute)
1. Must have a *request* section, that might contain the following optional fields:
  * *params*: string defining an example query
  * *headers*: key-values of the headers sent
  * *body*: the body of the request
1. Must have a *response* section, that might contain the following optional fields:
  * *status*: status of the response
  * *headers*: key-values of the headers received
  * *body*: the body of the response

The field *name* is used to defined, based on the value of the helper
```examples_regex```, if that example should be associated to that route.

The body can be free format.

A valid example and its association to a route are shown below.

*Route annotation:*

```ruby
  examples_regex 'myapp_get_*'
  get '/myapp' do
    'Hello'
  end
```

*Example:*
```yaml
---
action: GET /myapp
request:
  headers:
    MY-APP-ID: example-id
response:
  headers:
    content-type: text/plain;charset=utf-8
  status: 200
  body: 'Hello'
name: my_app_get_hello_example
description: Simple example of a GET that returns Hello
```

Once the examples are available and the routes are annotated accordingly, DocMyRoutes can be configured to load and parse all the files that match a given regexp.

```ruby
DocMyRoutes.configure do |config|
  config.examples_path_regexp = 'myapp/examples/*.yml'
end
```

## What kind of applications are supported?

DocMyRoutes can generate documentation for most Sinatra applications and it
also automatically detects when an application is mounted on a different path.

The following two examples both would work.

Using *map*:

```ruby
require_relative 'my_app'

app = Rack::Builder.app do
  map '/myapp' do
    run MyApp.new
  end
end

...

# If documentation requested (e.g., using an input flag)
DocMyRoutes::Documentation.generate

...
```

Or using *URLMap*:

```ruby
require_relative 'my_app'

app = Rack::Builder.app do
  run Rack::URLMap.new('/myapp' => MyApp.new)
end

...

# If documentation requested (e.g., using an input flag)
DocMyRoutes::Documentation.generate

...
```

## Customisation

Some aspects of DocMyRoutes can be customised to provide a different user
experience.

The next few sections describe the available settings; simply have code like
the following snippet to change those settings.

```ruby
require 'doc_my_routes'

DocMyRoutes.configure do |config|
  config.SETTING = MY_VALUE
end
```

### Customise title and description

The settings ```title``` and ```description``` control the
first section of the documentation and should always be configured.

### Destination directory

The setting ```destination_dir``` defines where to store the generated
documentation.

### Customise output

A custom CSS file can be provided to change the look and feel of the
documentation.

The setting ```css_file_path``` controls which file is going to be loaded and
used.

The simplified structure with custom classes of the current template is shown
in the following snippet and can be used a guideline of what can be easily
customised.

```css
section.documentation
  header
    info.title
    info.description

  section.resources
    article.resource (repeated for every resource)
      summary.resource
      article.operation {.get, .put, .post, .delete} (for every operation)
        summary.operation
        div.content {.get, .put, .post, .delete}
          ... actual content ...
          article.example {.get, .put, .post, .delete}
            summary.example {.get, .put, .post, .delete}
            div.example_content {.get, .put, .post, .delete}
              div.request
                div.code {.get, .put, .post, .delete}
                pre.request-code.query
                pre.request-code.headers
                pre.request-code.body
              div.response
                div.code {.get, .put, .post, .delete}
                pre.request-code.headers
                pre.request-code.body
```

### Configuring a custom logger

A custom logger can be provided using:

```ruby
require 'doc_my_routes'
DocMyRoutes.logger = MY_CUSTOM_LOGGER

class MyApp < Sinatra::Base
  extend DocMyRoutes::Annotatable

...
```

If a custom logger is not configured, a standard one that writes to STDOUT is provided by default.

## Known issues

* Multiple Rack applications inheriting from the same parent application are not
  supported at the moment. (see *spec/system/childapps_spec.rb* for an example)
* [Firefox](https://bugzilla.mozilla.org/show_bug.cgi?id=591737) and IE do not
  support the HTML5 *details* tag and hence the route section are not collapsible


## Contributing & License

Please refer to [CONTRIBUTING](CONTRIBUTING) and [LICENSE](LICENSE) for more information.
