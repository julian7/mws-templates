require 'generators/mws'

module Mws
  module Generators
    class LayoutGenerator < Base
      argument :layout_name, :type => :string, :default => 'application', :banner => 'layout name'

      def app_views_layouts_application
        template  'application.html.slim.erb', "app/views/layouts/#{file_name}.html.slim"
        copy_file 'application.scss', "public/stylesheets/sass/#{file_name}.scss"
        copy_file '978.scss', 'public/stylesheets/sass/includes/978.scss'
        copy_file 'helper.rb', 'app/helpers/layout_helper.rb'
        inject_into_file 'app/helpers/application_helper.rb', :after => "module ApplicationHelper\n" do
          "  helper :layout\n"
        end
      end

      def file_name
        layout_name.underscore
      end
    end
  end
end