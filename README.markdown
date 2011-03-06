# STOP!! #

## This repo is dead! Please [follow the v3.0 rewrite](https://github.com/bcardarella/client_side_validations) ##

# Client Side Validations
Now you can easily drop in client side validations in any Rails app. It will use validations defined in a given ActiveRecord (or ActiveModel) class for use with [jquery-validation](http://bassistance.de/jquery-plugins/jquery-plugin-validation/)

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
* validates_size_of
* validates_uniqueness_of
* validates_confirmation_of
* validates_acceptance_of
* validates_inclusion_of
* validates_exclusion_of

The uniqueness validation works for both ActiveRecord and Mongoid.

## Installation
> gem install client_side_validations

### Rails 2
Add "config.gem :client_side_validations" to the "config/environment.rb" file

Then run the generator:
   > script/generate client_side_validations

This will copy client_side_validations.js to "public/javascripts"

**This version of ClientSideValidations will also copy a patched version of jquery-validation.js to "public/javascript"**

### Rails 3
Add "gem 'client_side_validations'" to the Gemfile

Then run the generator:
   > rails g client_side_validations

This will copy client_side_validations.js to "public/javascripts"

**This version of ClientSideValidations will also copy a patched version of jquery-validation.js to "public/javascript"**

## Configuration
#### *NOTE* This version of ClientSideValidations has a patched version of jquery-validation that will install automatically with the generator. *Do not* download the version listed below.
Download [jQuery](http://docs.jquery.com/Downloading_jQuery) and [jQuery Validation](http://bassistance.de/jquery-plugins/jquery-plugin-validation/) plugin to "public/javascripts"

### Rack
As of version 2.9.0 the ClientSideValidations::Uniqueness middleware is automatically included as a Rails Engine. (both Rails 2 and Rails 3)

### Model
Validate your models as you normally would

    class Book < ActiveRecord::Base
      validates_presence_of :author
    end

### Layout
You currently need both jQuery and the jQuery Validate plugin loaded before you load Client Side Validations

    ...
    <%= javascript_include_tag 'jquery', 'jquery-validation', 'client_side_validations' %>
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

### Initialization
[jquery-validation can be customized by setting various options](http://docs.jquery.com/Plugins/Validation/validate#toptions)

Create config/initializers/client_side_validations.rb

An example set of default options can look like:

    ClientSideValidations.default_options = {
      :onkeyup    => false,
      :errorClass => "validation_errors"
    }
    
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
    

### View
You can override the default options set in the initializer for each form:

    <% form_for @book, :validations => { :options => { :errorClass => "bad-field" } } do |b| %>
      ...
      
If you are not using an instance variable for form_for or for some reason want to use the validations from another class that can be done in two ways:

    <% form_for :book, :validations => Book %>
      ...
      
    <% form_for :book, :validations => { :class => Book } %>
      ...
      
Written by Brian Cardarella

Copyright (c) 2010 Democratic National Committee. See LICENSE for details.
