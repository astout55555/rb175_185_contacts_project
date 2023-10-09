require 'pg'

class DatabasePersistence
  def initialize(logger)
    @db = if Sinatra::Base.production?
            PG.connect(ENV['DATABASE_URL'])
          else
            PG.connect(dbname: "contacts_db")
          end
    @logger = logger
  end

  def disconnect
    @db.close
  end

  def filtered_contacts(filters)
    all_contacts.select { |contact| filters.include?(contact[:category]) }
  end

  def all_contacts
    sql = <<~SQL
      SELECT * FROM contacts
    SQL

    result = query(sql)

    result.map { |tuple| tuple_to_contact_hash(tuple) }
  end

  def find_contact(id)
    all_contacts.find { |contact| contact[:id] == id }
  end

  def add_contact(name, phone, email, category)
    sql = <<~SQL
      INSERT INTO contacts (name, phone, email, category)
                    VALUES ($1, $2, $3, $4);
    SQL

    query(sql, name, phone, email, category)
  end

  def update_contact(id, name, phone, email, category)
    sql = <<~SQL
      UPDATE contacts
      SET name = $2, phone = $3, email = $4, category = $5
      WHERE id = $1
    SQL

    query(sql, id, name, phone, email, category)
  end

  def delete_contact(id)
    sql = <<~SQL
      DELETE FROM contacts WHERE id = $1
    SQL
    query(sql, id)
  end

  private

  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    @db.exec_params(statement, params)
  end

  def tuple_to_contact_hash(tuple)
    { id: tuple["id"],
      name: tuple["name"],
      phone: tuple["phone"],
      email: tuple["email"],
      category: tuple["category"] }
  end
end