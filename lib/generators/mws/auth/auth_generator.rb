require 'generators/mws'

module Mws
  module Generators
    class AuthGenerator < Base
      def application_controller
        inject_template_into_file "application_controller.rb.erb",
          "app/controllers/application_controller.rb", :before => "\nend"
      end
      def rspec_helper
        copy_file 'rspec_support_devise.rb', 'spec/support/devise.rb'
      end

      def cancan_files
        copy_file 'ability.rb', 'app/model/ability.rb'
      end
    end
  end
end