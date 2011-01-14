module Mws
  module Generators
    class Base < Rails::Generators::Base
      def self.source_root
        @_source_root ||= File.expand_path("../mws/#{generator_name}/templates", __FILE__)
      end

      def self.banner
        super.sub(/^rails generate /, "rails generate mws:")
      end

      def self.app_name
        Rails.application.class.parent.to_s
      end

      protected

      def inject_template_into_file(*args, &block)
        source = File.expand_path(find_in_source_paths(args.shift.to_s))
        context = instance_eval('binding')
        inject_into_file(*args) do
          contents = ERB.new(::File.binread(source), nil, '-', '@output_buffer').result(context)
          contents = block.call(contents) if block
          contents
        end
      end
    end
  end
end