module CarrierWave
  module Storage
    class Cascade < Abstract
      attr_reader :primary_storage, :secondary_storage

      def initialize(*args)
        super(*args)

        @primary_storage   = get_storage(uploader.primary_storage)
        @secondary_storage = get_storage(uploader.secondary_storage)
      end

      def store!(*args)
        primary_storage.store!(*args)
      end

      def retrieve!(*args)
        primary_file = primary_storage.retrieve!(*args)

        if !primary_file.exists?
          secondary_file = secondary_storage.retrieve!(*args)
          return SecondaryFileProxy.new(uploader, secondary_file)
        else
          return primary_file
        end
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

      class SecondaryFileProxy
        attr_reader :real_file

        def initialize(uploader, real_file)
          @uploader = uploader
          @real_file = real_file
        end

        def delete
          if true === @uploader.allow_secondary_file_deletion
            return real_file.delete
          else
            return true
          end
        end

        def method_missing(*args, &block)
          real_file.send(*args, &block)
        end

        def method(name)
          real_file.method(name)
        end

        def respond_to?(*args)
          @real_file.respond_to?(*args)
        end
      end
    end
  end
end
