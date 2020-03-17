module SidekiqAlive
  class Config
    include Singleton

    attr_accessor :port,
                  :readiness_check,
                  :liveness_check,
                  :token,
                  :server_logger



    def initialize
      set_defaults
    end

    def set_defaults
      @port = ENV['SIDEKIQ_ALIVE_PORT'] || 7433
      @readiness_check = Proc.new { true }
      @liveness_check = Proc.new { true }
      @token = "test-token"
      @server_logger = Sidekiq.logger
    end
  end
end
