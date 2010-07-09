# Client Side Validations
Now you can easily drop in client side validations in any Rails app. It will use validations defined in a given ActiveRecord (or ActiveModel) class for use with a Javascript form validator. (currently only [jquery.validate](http://bassistance.de/jquery-plugins/jquery-plugin-validation/) is supported)

For Rails 2 and Rails 3 example apps please see [client_side_validations_example](http://github.com/dnclabs/client_side_validations_examples)

The concept is simple:

1. Include the middleware
2. Define validations in the model as you normally would
3. The validations are sent to the client in JSON
4. client_side_validations.js converts the JSON for a given validation plugin and binds the validator to the form

Currently the following validations are supported:

* validates_presence_of
* validates_format_of
* validates_numericality_of
* validates_length_of
* validates_uniqueness_of
* validates_confirmation_of

The uniqueness validation works for both ActiveRecord and Mongoid.

## Installation
> gem install client_side_validations

### Rails 2
Add "config.gem :client_side_validations" to the "config/environment.rb" file

Then run the generator:
   > script/generate client_side_validations

This will copy client_side_validations.js to "public/javascripts"

### Rails 3
Add "gem 'client_side_validations" to the Gemfile

Then run the generator:
   > rails g client_side_validations

This will copy client_side_validations.js to "public/javascripts"

## Configuration
Currently only [jquery.validate](http://bassistance.de/jquery-plugins/jquery-plugin-validation/) is supported so you will need to download [jQuery](http://docs.jquery.com/Downloading_jQuery) and the jQuery Validate plugin to "public/javascripts"

### Rack
If you want to validate_uniqueness_of a call to the server must be made. You can do this by simply drop in the ClidenSideValidations Rack middleware.

The following route will be reserved for client side validations:

/validations/uniqueness.json

Add the middleware to your stack:

config/environment.rb for Rails 2.x

config/application.rb for Rails 3.x

    ...
    config.middleware.use 'ClientSideValidations::Uniqueness'
    ...

### Model
Validate your models as you normally would

    class Book < ActiveRecord::Base
      validates_presence_of :author
    end

### Layout
You currently need both jQuery and the jQuery Validate plugin loaded before you load Client Side Validations

    ...
    <%= javascript_include_tag 'jquery', 'jquery.validate', 'client_side_validations' %>
    ...
   
### View
Have a form ask for client side validations by passing :validate => true

    ...
    
    <% form_for @book, :validations => true do |b| %>
      <%= b.label :author %></br>
      <%= b.text_field :author %></br>
      <%= submit_tag 'Create' %>
    <% end %>
    
    ...
   
That should be it!

## Advanced Options

### Model
If you want to define only specific fields for client side validations just override the validation_fields method on each model

    class Book < ActiveRecord::Base
      validatese_presence_of :author
      validates_presence_of :body
      
      private
      
      def validation_fields
        [:author]
      end
    end
    

Written by Brian Cardarella

Copyright (c) 2010 Democratic National Committee. See LICENSE for details.
