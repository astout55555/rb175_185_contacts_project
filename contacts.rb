require "sinatra"
require "sinatra/content_for"
require "tilt/erubis"

require_relative "session_persistence"

configure do
  enable :sessions
  set :session_secret, SecureRandom.hex(32)
  set :erb, :escape_html => true
end

configure(:development) do
  require "sinatra/reloader"
  also_reload "session_persistence.rb"
end

helpers do
  
end

before do
  @session = SessionPersistence.new(session)
end

after do
  
end

get "/" do
  redirect "/contacts"
end

get "/contacts" do
  @contacts = @session.all_contacts
  erb :contacts
end

get "/contacts/new" do
  erb :new_contact
end

post "/contacts/new" do
  new_contact = params[:new_contact]
  @session.add_contact(new_contact)
  redirect "/contacts"
end
