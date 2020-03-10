require 'rack/test'
require 'net/http'
RSpec.describe SidekiqAlive::Server do
  include Rack::Test::Methods

  subject(:app) { described_class }

  describe 'responses' do
    describe "/-/liveness" do
      it "responds with success" do
        get '/-/liveness'
        expect(last_response).to be_ok
        expect(last_response.body).to eq('OK')
      end
    end

    describe "/-/readiness" do
      it "responds with ok if the service is ready" do
        allow(SidekiqAlive).to receive(:ready?) { true }
        get '/-/readiness'
        expect(last_response).to be_ok
        expect(last_response.body).to eq("OK")
      end

      it "responds with an error when the service is not ready" do
        allow(SidekiqAlive).to receive(:ready?) { false }
        get '/-/readiness'
        expect(last_response).not_to be_ok
        expect(last_response.body).to eq("KO")
      end
    end
  end

  describe 'SidekiqAlive setup' do
    before do
      ENV['SIDEKIQ_ALIVE_PORT'] = '4567'
      SidekiqAlive.config.set_defaults
    end

    after do
      ENV['SIDEKIQ_ALIVE_PORT'] = nil
    end

    it 'respects the SIDEKIQ_ALIVE_PORT environment variable' do
      expect( described_class.port ).to eq '4567'
    end
  end
end
