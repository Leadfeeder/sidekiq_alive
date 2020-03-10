require 'sinatra/base'
module SidekiqAlive
  class Server < Sinatra::Base
    set :bind, '0.0.0.0'
    set :port, -> { SidekiqAlive.config.port }

    get '/' do
      status 404
      body ""
    end

    get '/-/liveness' do
      if SidekiqAlive.alive?
        status 200
        body "OK"
      else
        status 404
        body "KO"
      end
    end

    get '/-/readiness' do
      if SidekiqAlive.ready?
        status 200
        body "OK"
      else
        status 404
        body "KO"
      end
    end
  end
end
