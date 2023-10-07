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
  def select_if_current_category(contact, category)
    "selected" if contact[:category] == category
  end

  def check_if_selected(filters, category) # I'll see about adding this to contacts.erb after I get the filtering to work...
    "checked" if filters.include?(category)
  end
end

before do
  @storage = SessionPersistence.new(session)
end

after do
  
end

# View all contacts (front page)
get "/" do
  redirect "/contacts"
end

get "/contacts" do
  @filters = ["friends", "family", "work", "other"]
  @contacts = @storage.all_contacts
  erb :contacts
end

get "/contacts/filtered" do
  @filters = @storage.filters
  @contacts = @storage.filtered_contacts(@filters)
  erb :contacts
end

post "/contacts/filtered" do
  @storage.select_filters(params[:filters])
  redirect "/contacts/filtered"
end

# View new contact page
get "/contacts/new" do
  erb :new_contact
end

# Form to add a new contact
post "/contacts/new" do
  contact_name = params[:name]
  phone = params[:phone]
  email = params[:email]
  category = params[:category]
  @storage.add_contact(contact_name, phone, email, category)
  redirect "/contacts"
end

# Pull up a single contact's details based on contact id from link
get "/contact/:id" do
  id = params[:id]
  @contact = @storage.find_contact(id)
  erb :contact
end

# View contact editing page
get "/contact/:id/edit" do
  id = params[:id]
  @contact = @storage.find_contact(id)
  erb :edit_contact
end

# Contact editing form
post "/contact/:id/edit" do
  id = params[:id]
  name = params[:name]
  phone = params[:phone]
  email = params[:email]
  category = params[:category]
  @storage.update_contact(id, name, phone, email, category)
  redirect "/contact/#{id}"
end

# Delete contact
post "/contact/:id/destroy" do
  id = params[:id]
  @storage.delete_contact(id)
  redirect "/contacts"
end
