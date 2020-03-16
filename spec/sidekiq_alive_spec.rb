RSpec.describe SidekiqAlive do

  it "has a version number" do
    expect(SidekiqAlive::VERSION).not_to be nil
  end

  it 'configures the port from the #setup' do
    described_class.setup do |config|
      config.port = 4567
    end

    expect( described_class.config.port ).to eq 4567
  end

  it 'configures the port from the SIDEKIQ_ALIVE_PORT ENV var' do
    ENV['SIDEKIQ_ALIVE_PORT'] = '4567'

    SidekiqAlive.config.set_defaults

    expect( described_class.config.port ).to eq '4567'

    ENV['SIDEKIQ_ALIVE_PORT'] = nil
  end

  it 'configurations behave as expected' do
    k = described_class.config
    expect(k.port).to eq 7433
    k.port = 4567
    expect(k.port).to eq 4567
  end

  it '::hostname' do
    expect(SidekiqAlive.hostname).to eq 'test-hostname'
  end

  it "::alive?" do
    expect(SidekiqAlive.alive?).to be true
  end

  it "::ready?" do
    expect(SidekiqAlive.ready?).to be true
  end
end
