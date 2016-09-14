module CarrierWave
  module Storage
    class Cascade < Abstract
      attr_reader :primary_storage, :secondary_storage, :enable_cascade

      def initialize(*args)
        super(*args)

        @primary_storage   = get_storage(uploader.primary_storage)
        @secondary_storage = get_storage(uploader.secondary_storage)
        @enable_cascade = uploader.enable_cascade
      end

      def store!(*args)
        primary_storage.store!(*args)
      end

      def retrieve!(*args)
        primary_file = primary_storage.retrieve!(*args)
        return primary_file unless enable_cascade && !primary_file.exists?

        secondary_file = secondary_storage.retrieve!(*args)
        SecondaryFileProxy.new(uploader, secondary_file)
      end

      private

      def get_storage(storage)
        if storage.is_a?(Symbol)
          storage_type = storage
          uploader = self.uploader
        else
          storage_type = storage[:storage]
          uploader = CarrierWave::Uploader::Cascade.new(self.uploader, storage)
        end

        storage_class(storage_type).new(uploader)
      end

      def storage_class(storage_type)
        storage_type.is_a?(Symbol) ?
          constantize(uploader.storage_engines[storage_type]) :
          storage_type
      end

      def constantize(string)
        string.split('::').reduce(Object, :const_get)
      end

      class SecondaryFileProxy < ::SimpleDelegator
        alias real_file __getobj__
        private :__setobj__

        def initialize(uploader, real_file)
          @uploader = uploader
          __setobj__(real_file)
        end

        def delete
          return real_file.delete if @uploader.allow_secondary_file_deletion
          true
        end
      end
    end
  end
end
