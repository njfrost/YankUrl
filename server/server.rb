require 'rubygems'
require 'pathname'
require 'bundler'
Bundler.require

class Controller < Sinatra::Base
  root_path = File.dirname(File.dirname(__FILE__))
  APP_PORT = "9989"
  APP_ROOT = Pathname.new(root_path).realpath.to_s #find full path to this file
  APP_DOMAIN = "localhost:#{APP_PORT}" #Can this be pushed to a higher level, Bundler.require?

  set :keys, "#{APP_ROOT}/keys"
  set :views, "#{APP_ROOT}/server/views"
  set :haml, :format => :html5

  helpers do
    def gen_id
      (0..15).collect{(rand*16).to_i.to_s(16)}.join
    end
    def save_page key, url
        path = File.join(APP_ROOT, "keys/#{key}")
        File.open(path, 'w') { |file| file.write(url) }
    end
    def redirect_page key
        path = File.join(APP_ROOT, "keys/#{key}")
        return false unless File.file? path
        File.open(path, 'r') { |file| file.read }
    end
  end

  get '/' do
    haml :userPage, :locals => { :userName => "default" } 
  end
  get %r{^/([a-zA-Z0-9-]+)$} do |name|
    redirect redirect_page name unless false 
  end
  
  get %r{^/([a-zA-Z0-9-]+)/add$} do |name|
    haml :userPage, :locals => { :userName => name } 
  end
  get '/*/p/*' do |name, url|
    save_page name,url
  end
end
