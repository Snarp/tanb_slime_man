require 'rubygems'
require 'bundler'
Bundler.require
require 'dotenv/load'
require './main.rb'

map '/assets' do
  environment = Sprockets::Environment.new
  environment.append_path 'app/assets/javascripts'
  environment.append_path 'app/assets/stylesheets'
  run environment
end

run Sinatra::Application
