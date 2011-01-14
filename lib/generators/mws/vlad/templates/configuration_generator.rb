class ConfigurationGenerator < Rails::Generators::Base
  argument :target_env, :type => :string, :default => 'production', :banner => "target_environment"
  source_root File.expand_path('../templates', __FILE__)

  def unicorn_config
    template 'unicorn.god.erb', 'config/unicorn.god'
  end
end
