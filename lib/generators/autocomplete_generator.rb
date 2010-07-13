require 'rails/generators'

class AutocompleteGenerator < Rails::Generators::Base
  def install
    # Copy the unobtrusive JS file
    copy_file('autocomplete-rails.js', 'public/autocomplete-rails.js')
    # Rails initializer
    copy_file('autocomplete.rb', 'config/initializers/autocomplete.rb')
  end

  def self.source_root
    File.join(File.dirname(__FILE__), 'templates')
  end
end