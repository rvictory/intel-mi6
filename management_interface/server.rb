# server.rb - Management interface for the intel engine
# Author: Ryan Victory
# Issues: None

require 'sinatra'

class Server < Sinatra::Base

  configure do

  end

  helpers do

  end

  get '/' do
    erb :index
  end

end