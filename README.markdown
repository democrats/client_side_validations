# Client Side Validations
Now you can easily drop in client side validations in any Rails app. It will use validations defined in a given ActiveRecord (or ActiveModel) class for use with a Javascript form validator. (currently only [jquery.validate](http://bassistance.de/jquery-plugins/jquery-plugin-validation/) is supported)

The concept is simple:

1. Define validations in the model as you normally would
2. Provide a publicly available route that render client_side_validations from the instance of the model
3. The validations are sent to the client in JSON
4. client_side_validations.js converts the JSON for a given validation plugin and binds the validator to the form

Currently the following validations are supported:

* validates_presence_of
* validates_format_of
* validates_numericality_of
* validates_length_of

## Installation
> gem install client_side_validations

## Rails 2
Add "config.gem :client_side_validations" to the "config/environment.rb" file

Then run the generator:
   > script/generate client_side_validations

This will copy client_side_validations.js to "public/javascripts"

## Rails 3
Add "gem 'client_side_validations" to the Gemfile

Then run the generator:
   > rails g client_side_validations

This will copy client_side_validations.js to "public/javascripts"

## Configuration
Currently only [jquery.validate](http://bassistance.de/jquery-plugins/jquery-plugin-validation/) is supported so you will need to download [jQuery](http://docs.jquery.com/Downloading_jQuery) and the jQuery Validate plugin to "public/javascripts"

### Model
Validate your models as you normally would

    class Book < ActiveRecord::Base
      validates_presence_of :author
    end

### Controller
The controller action just needs to render the validations in JSON. From an instance of the model.
    ...
    
    def new
      @book = Book.new
     
      respond_to do |format|
        format.html
        format.json { render :json => @book.validations_to_json(:author) }
      end
    end
    
    ...
   
### Layout
You currently need both jQuery and the jQuery Validate plugin loaded before you load Client Side Validations
    ...
    <%= javascript_include_tag 'jquery', 'jquery.validate', 'client_side_validations' %>
    ...
   
### View
Have a form ask for client side validations by passing :validate to form_for and pass the url of the action defined in the controller
    ...
    
    <% form_for @book, :validations => { :url => new_book_path(:format => :json) } do |b| %>
       <%= b.label :author %></br>
       <%= b.text_field :author %></br>
       <%= submit_tag 'Create' %>
    <% end %>
    
    ...
   
That should be it!

Copyright (c) 2010 Democratic National Committee. See LICENSE for details.
