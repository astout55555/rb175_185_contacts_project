class SessionPersistence
  def initialize(session)
    @session = session
    @session[:contacts] ||= []
  end

  def all_contacts
    @session[:contacts]
  end

  def add_contact(new_contact)
    @session[:contacts] << new_contact
  end
end