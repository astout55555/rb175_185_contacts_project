require "sinatra"
require "sinatra/content_for"
require "tilt/erubis"

require_relative "database_persistence" # "persistence_testing"

configure do
  enable :sessions
  set :session_secret, SecureRandom.hex(32)
  set :erb, :escape_html => true
end

configure(:development) do
  require "sinatra/reloader"
  also_reload "database_persistence.rb" # "persistence_testing.rb"
end

helpers do
  def select_if_current_category(contact, category)
    "selected" if contact[:category] == category
  end

  def check_if_selected(filters, category)
    "checked" if filters.include?(category)
  end
end

before do
  @storage = DatabasePersistence.new(logger) # TestingPersistence.new(session)
end

after do
  @storage.disconnect
end

def error_for_name(name)
  if name.strip.empty? || name.split.any?(/([^A-Z^a-z^\.^'])/)
    "Please enter a valid name."
  end
end

def retrieve_digits(phone)
  phone.chars.select { |char| char.match?(/[0-9]/) }.join
end

def error_for_phone(digits)
  if (digits.size) != 10
    "Please enter a valid phone number."
  end
end

# View all contacts (front page)
get "/" do
  redirect "/contacts"
end

# Separate route/url so that one way of resetting filters is to navigate back to the home page
get "/contacts" do
  @filters = ["friends", "family", "work", "other"]
  @contacts = @storage.all_contacts
  erb :contacts
end

# View filtered contacts
get "/contacts/filtered" do
  @filters = params[:filters] ||= []
  @contacts = @storage.filtered_contacts(@filters)
  erb :contacts
end

# View new contact page
get "/contacts/new" do
  erb :new_contact
end

# Add a new contact
post "/contacts/new" do 
  name = params[:name].strip
  phone = params[:phone]
  phone_digits = retrieve_digits(params[:phone])
  email = params[:email]
  category = params[:category]

  error = error_for_name(name) || error_for_phone(phone_digits)
  if error
    session[:error] = error
    erb :new_contact
  else
    session[:success] = "Contact successfully added."
    @storage.add_contact(name, phone_digits, email, category)
    redirect "/contacts"
  end
end

# View a single contact's details based on contact id from link
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

# Update contact details
post "/contact/:id/edit" do
  id = params[:id]
  name = params[:name]
  phone = params[:phone]
  phone_digits = retrieve_digits(phone)
  email = params[:email]
  category = params[:category]

  error = error_for_name(name) || error_for_phone(phone_digits)
  if error
    session[:error] = error
    @contact = @storage.find_contact(id)
    erb :edit_contact
  else
    session[:success] = "Contact successfully updated."
    @storage.update_contact(id, name, phone_digits, email, category)
    redirect "/contact/#{id}"
  end
end

# Delete contact
post "/contact/:id/destroy" do
  id = params[:id]
  @storage.delete_contact(id)
  redirect "/contacts"
end
