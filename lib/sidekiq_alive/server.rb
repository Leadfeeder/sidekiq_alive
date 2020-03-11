require 'sinatra/base'
module SidekiqAlive
  class Server < Sinatra::Base
    set :bind, '0.0.0.0'
    set :port, -> { SidekiqAlive.config.port }

    before do
      token = params["token"] || headers["TOKEN"]

      unless Rack::Utils.secure_compare(token.to_s, SidekiqAlive.config.token)
        halt 401
      end
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

    get '/*' do
      status 404
      body "did you mean /-/liveness or /-/readiness ?"
    end
  end
end
