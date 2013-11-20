# Carrierwave::Cascade

[![Build Status](https://travis-ci.org/kjg/carrierwave-cascade.png?branch=master)](https://travis-ci.org/kjg/carrierwave-cascade)

A storage plugin for carrierwave that will retrieve files from a
secondary storage if the file is not present in the primary storage.
New files will always be stored in the primary storage. This is
perfect for use while migrating from one storage to another, or to
avoid polluting a production environment when running a staging
mirror.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'carrierwave-cascade'
```

## Usage

Configure carrierwave to use Cascade as its storage engine. Then set
primary and secondary storages to be used. Supply other
configuration as needed for the storages.

```ruby
CarrierWave.configure do |config|
  config.storage    = :cascade
  config.primary_storage   = :file
  config.secondary_storage = :fog

  config.fog_credentials = {
    :provider               => 'AWS'
  }
end
```

It's also possible override top level settings for both primary and
secondary storages as necessary. This makes it possible to use the
same storage engine for both storages while pointing to different
backends, using different credentials, etc.. Use a Hash instead of a
Symbol in this case, setting the storage type by way of the :storage
key, and override any settings as necessary within the hash.

```ruby
CarrierWave.configure do |config|
  config.storage    = :cascade

  # Use Fog for the primary storage with the OpenStack provider.
  config.primary_storage   = :fog
  config.fog_credentials = {
    :provider               => 'OpenStack'
  }

  # Use Fog again for the secondary storage, but with the AWS
  # provider as the backend this time.
  config.secondary_storage = {
    :storage => :fog,
    :fog_credentials => {
      :provider             => 'AWS'
    }
  }
end
```

The above also allows arbitrarily deep nesting of storages. Use the
:cascade type as the storage in the Hash in this case and continue
as before with nested Hashes.

```ruby
CarrierWave.configure do |config|
  config.storage    = :cascade

  # Use Fog for the primary storage with the OpenStack provider.
  config.primary_storage   = :fog
  config.fog_credentials = {
    :provider               => 'OpenStack'
  }

  # Use Cascade for the secondary storage.
  config.secondary_storage = {
    :storage => :cascade,

    # Use Fog again for the next level down, but with the AWS
    # provider.
    # NOTE: Even though this is a primary storage, store! attempts
    #       won't reach here since this isn't the top level of the
    #       cascade.
    :primary_storage => {}
      :storage => :fog,
      :fog_credentials => {
        :provider             => 'AWS'
      }
    }

    # Turtles all the way down maybe...
    :secondary_storage => {
      :storage => :cascade,
      :primary_storage => ...
      :secondary_storage => ...
    }
  }
end
```

By default, cascade will prevent files from being deleted out of the
secondary storage. If you wish secondary storage file to be deleted,
specify this in the configs.

```ruby
CarrierWave.configure do |config|
  config.allow_secondary_file_deletion = true
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
