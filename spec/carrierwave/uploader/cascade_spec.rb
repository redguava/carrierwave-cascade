require 'spec_helper'

describe CarrierWave::Uploader::Cascade do
  let(:uploader){ CarrierWave::Uploader::Base.new }
  let(:storage_config){ {:storage => :file} }

  subject(:cascade_uploader){ CarrierWave::Uploader::Cascade.new(uploader, {:storage => :fog, :override_me => :overridden}) }

  before do
    CarrierWave::Uploader::Base.add_config(:override_me)
    CarrierWave::Uploader::Base.add_config(:inherit_me)
    CarrierWave::Uploader::Base.configure do |config|
      config.override_me = :original
      config.inherit_me = :inherited
    end
  end

  it "overrides uploader settings using the settings hash" do
    expect(cascade_uploader.override_me).to eql(:overridden)
  end

  it "inherits uploader settings not overridden the settings hash" do
    expect(cascade_uploader.inherit_me).to eql(:inherited)
  end

  it "delegates to the upstream uploader for unknown methods" do
    expect(uploader).to receive(:delegated).with('argument')
    cascade_uploader.delegated('argument')
  end
end
