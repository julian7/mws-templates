class ConfigurationGenerator < Rails::Generators::Base
  class_option :unicorn, :desc => "generate unicorn.god",  :type => :boolean, :default => true
  class_option :resque, :desc => "generate resque.god",  :type => :boolean, :default => false
  source_root File.expand_path('../templates', __FILE__)

  def unicorn_config
    template 'unicorn.god', 'config/unicorn.god' if options[:unicorn]
    template 'resque.god', 'config/resque.god' if options[:resque]
  end
end
