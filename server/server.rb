require 'rubygems'
require 'pathname'
require 'bundler'
Bundler.require

class Controller < Sinatra::Base
  root_path = File.dirname(File.dirname(__FILE__))
  #APP_PORT = "9989"
  APP_ROOT = Pathname.new(root_path).realpath.to_s #find full path to this file
  APP_DOMAIN = "http://yankurl.heroku.com/" #Can this be pushed to a higher level, Bundler.require?
  #APP_DOMAIN = "http://localhost:9899" #Can this be pushed to a higher level, Bundler.require?
  RE_USER = "[a-zA-Z0-9-]+"

  set :keys, "#{APP_ROOT}/keys"
  set :views, "#{APP_ROOT}/server/views"
  set :haml, :format => :html5

  $userPageHash = Hash.new

  helpers do
    def gen_id
      (0..15).collect{(rand*16).to_i.to_s(16)}.join
    end
    def save_page key, url
        setUserPageHash key, url
    end
    def redirect_page key
        getUserPageHashValue key
    end
    def pasteURL userName
        url = "#{APP_DOMAIN}/#{userName}/p/"
    end
    def copyURL userName
        url = "#{APP_DOMAIN}/#{userName}/c/"
    end
    def setUserPageHash user, url
        if $userPageHash == nil
            $userPageHash = Hash.new
        end
        $userPageHash[user] = url
    end
    def getUserPageHashValue user
        if $userPageHash == nil
            $userPageHash = Hash.new
        end
        $userPageHash[user]
    end
    def setUserPageFile user, url
        path = File.join(APP_ROOT, "keys/#{key}")
        File.open(path, 'w') { |file| file.write(url) }
    end
    def getUserPageFile user
        path = File.join(APP_ROOT, "keys/#{key}")
        return nil unless File.file? path
        File.open(path, 'r') { |file| file.read }
    end
  end

  get '/' do
    haml :userPage, :locals => { :userName => "SomeRandomUser" } 
  end
  get %r{^/([a-zA-Z0-9-]+)/p/$} do |name|
    redirect redirect_page name unless nil 
  end
  
  get %r{^/add/([a-zA-Z0-9-]+)$} do |name|
    haml :userPage, :locals => { :userName => name, :pasteURL => pasteURL(name), :copyURL => copyURL(name) } 
  end
  get '/*/c/*' do |name, url|
    save_page name,url
  end
end
