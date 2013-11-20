module CarrierWave
  module Uploader
    class Cascade
      def initialize(uploader, storage_config)
        @uploader, @storage_config = uploader, storage_config

        metaclass = class << self; self; end
        storage_config.each_key do |meth|
          metaclass.send(:define_method, meth) do
            storage_config[meth]
          end
        end
      end

      def method_missing(meth, *args, &block)
        @uploader.send(meth, *args, &block)
      end

      def respond_to?(meth, include_private = false)
        return true if super
        @uploader.respond_to?(meth, include_private)
      end

      private

      attr_reader :uploader, :storage_config
    end
  end
end
