require 'sidekiq'
require 'sidekiq/api'
require 'singleton'
require 'sidekiq_alive/version'
require 'sidekiq_alive/config'

module SidekiqAlive
  def self.start
    Sidekiq.configure_server do |sq_config|
      sq_config.on(:startup) do
        SidekiqAlive.tap do |sa|
          sa.logger.info(banner)
          @server_pid = fork do
            sa::Server.run!
          end
          sa.logger.info(successful_startup_text)
        end
      end

      sq_config.on(:shutdown) do
        Process.kill('TERM', @server_pid) unless @server_pid.nil?
        Process.wait(@server_pid) unless @server_pid.nil?
      end
    end
  end

  # CONFIG ---------------------------------------

  def self.setup
    yield(config)
  end

  def self.logger
    Sidekiq.logger
  end

  def self.config
    @config ||= SidekiqAlive::Config.instance
  end

  def self.hostname
    ENV['HOSTNAME'] || 'HOSTNAME_NOT_SET'
  end

  def self.ready?
    config.readiness_check.call
  end

  def self.alive?
    config.liveness_check.call
  end

  def self.shutdown_info
    <<~BANNER

    =================== Shutting down SidekiqAlive =================

    Hostname: #{hostname}

    BANNER
  end

  def self.banner
    <<~BANNER

    =================== SidekiqAlive =================

    Hostname: #{hostname}
    Port: #{config.port}

    starting ...
    BANNER
  end

  def self.successful_startup_text
    <<~BANNER
    =================== SidekiqAlive Ready! =================
    BANNER
  end
end

require 'sidekiq_alive/server'

SidekiqAlive.start if ENV['SIDEKIQ_ALIVE']
