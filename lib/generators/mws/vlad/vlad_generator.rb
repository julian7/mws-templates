require 'generators/mws'

module Mws
  module Generators
    class VladGenerator < Base
      class_option :repo, :desc => "GIT repository", :type => :string, :default => "git@github.com/USERNAME/#{app_name.underscore}.git"
      class_option :env, :desc => "Create configuration for an extra environment", :type => :string

      def default_tasks
        copy_file 'vlad.rake', 'lib/tasks/vlad.rake'
        copy_file 'god.rb', 'lib/vlad/god.rb'
      end

      def create_configs
        copy_file 'unicorn.rb', 'config/unicorn.rb'
        template 'deploy.rb.erb', 'config/deploy.rb'
        if options.env?
          template 'deploy_env.rb.erb', "config/deploy_#{options.env.underscore}.rb"
        end
      end

      def deploy_rake_task
        copy_file 'deploy.rake', 'lib/tasks/deploy.rake'
      end

      def configuration_generator
        copy_file 'configuration_generator.rb', 'lib/generators/configuration/configuration_generator.rb'
        copy_file 'configuration_USAGE', 'lib/generators/configuration/USAGE'
        copy_file 'configuration_unicorn.god.erb', 'lib/generators/configuration/templates/unicorn.god.erb'
      end
    end
  end
end