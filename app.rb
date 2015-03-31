require 'sinatra'
require 'sinatra/flash'
require 'slim'
require 'yaml'

enable :sessions
set :session_secret, ENV['SESSION_SECRET']

EMAIL_REGEX = /\A[\w\-.]+@[a-z\-\d]+(\.[a-z]+)*\.[a-z]+\z/i

configure do
  set config: YAML.load_file('config.yml')
  set header: { 'Accept' => "application/json; charset=utf-8" }
end

get '/' do
  slim :new
end

post '/register' do
  if valid_email?( params[:email] )
    send_invite
    flash[:notice] = "Invite sent"
  else
    flash[:notice] = "Invalid email"
  end

  redirect to('/')
end

def send_invite
  query = invite_params.merge( load_configs )
  HTTParty.post(build_uri, header: settings.header, query: query)
end

def invite_params
  params.select { |k,v| ["first_name", "last_name", "email"].include?(k) }
end

def load_configs
  settings.config["params"].merge({:set_active => "true"})
end

def build_uri
  "https://#{settings.config["hostname"]}.slack.com/api/users.admin.invite?t=#{Time.now.to_i.to_s}"
end

def valid_email?(email)
  email.match(EMAIL_REGEX)
end
