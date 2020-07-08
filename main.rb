require 'rubygems'
require 'bundler'
Bundler.setup :default
require 'sinatra'
require 'sinatra/json'
require 'encrypted_cookie'
require 'omniauth-tumblr'
require 'sprockets'
require 'uglifier'
require 'sass'
require 'yaml'

set :root,            File.dirname(__FILE__)
set :app_file,        __FILE__
set :show_exceptions, true
set :logging,         true
set :dump_errors,     true

use Rack::Session::EncryptedCookie, secret: ENV['SESSION_SECRET'], expire_after: 2592000
# enable :sessions
# set :session_secret,  ENV['SESSION_SECRET']

configure :production, :development do
  enable :logging
end
configure :test do
  # rspec context looks for views relative to /spec dir unless specified
  set :views, File.dirname(__FILE__) + '/../views'
end

use OmniAuth::Builder do
  provider :tumblr, ENV['TUMBLR_CONSUMER_KEY'], ENV['TUMBLR_CONSUMER_SECRET']
end

Dir.glob('app/**/*.rb').each { |fname| require_relative(fname) }
Dir.glob('lib/**/*.rb').each { |fname| require_relative(fname) }

helpers do
  include ApplicationHelpers
  include TumblrHelpers
end