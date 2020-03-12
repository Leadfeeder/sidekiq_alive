require 'rack/test'
require 'net/http'
RSpec.describe SidekiqAlive::Server do
  include Rack::Test::Methods

  subject(:app) { described_class }

  let(:token) { SidekiqAlive.config.token }

  describe 'responses' do
    describe "/-/liveness" do
      it "responds with success" do
        get "/-/liveness?token=#{token}"
        expect(last_response).to be_ok
        expect(last_response.body).to eq('OK')
      end

      it "responds with success when the token header is used" do
        header 'TOKEN', token
        get "/-/liveness"
        expect(last_response).to be_ok
        expect(last_response.body).to eq('OK')
      end

      it "responds with 401 if token is invalid" do
        get "/-/liveness?token=foo"
        expect(last_response).not_to be_ok
        expect(last_response.body).to eq("")
      end
    end

    describe "/-/readiness" do
      it "responds with ok if the service is ready" do
        allow(SidekiqAlive).to receive(:ready?) { true }
        get "/-/readiness?token=#{token}"
        expect(last_response).to be_ok
        expect(last_response.body).to eq("OK")
      end

      it "responds with ok if the service is ready and the token header is used" do
        allow(SidekiqAlive).to receive(:ready?) { true }
        header 'TOKEN', token
        get "/-/readiness"
        expect(last_response).to be_ok
        expect(last_response.body).to eq("OK")
      end

      it "responds with an error when the service is not ready" do
        allow(SidekiqAlive).to receive(:ready?) { false }
        get "/-/readiness?token=#{token}"
        expect(last_response).not_to be_ok
        expect(last_response.body).to eq("KO")
      end

      it "responds with 401 if token is invalid" do
        get "/-/readiness?token=foo"
        expect(last_response).not_to be_ok
        expect(last_response.body).to eq("")
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
