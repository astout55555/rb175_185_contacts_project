class SessionPersistence
  def initialize(session)
    @session = session
    @session[:contacts] ||= []
    @session[:filters] ||= []
  end

  def filters
    @session[:filters]
  end

  def set_filters(filters)
    @session[:filters] = filters
  end

  def filtered_contacts(filters)
    all_contacts.select { |contact| filters.include?(contact[:category]) }
  end

  def all_contacts
    @session[:contacts]
  end

  def find_contact(id)
    @session[:contacts].find { |contact| contact[:id] == id }
  end

  def add_contact(name, phone, email, category)
    new_contact = {
      id: next_contact_id,
      name: name,
      phone: phone,
      email: email,
      category: category
    }
    @session[:contacts] << new_contact
  end

  def update_contact(id, name, phone, email, category)
    contact = find_contact(id)
    contact[:name] = name
    contact[:phone] = phone
    contact[:email] = email
    contact[:category] = category
  end

  def delete_contact(id)
    @session[:contacts].reject! { |contact| contact[:id] == id }
  end

  private

  def next_contact_id
    max = all_contacts.map { |contact| contact[:id].to_i }.max || 0
    (max + 1).to_s
  end
end