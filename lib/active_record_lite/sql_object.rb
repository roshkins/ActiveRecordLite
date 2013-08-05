require_relative './associatable'
require_relative './db_connection'
require_relative './mass_object'
require_relative './searchable'

class SQLObject < MassObject

  extend Searchable
  extend Associatable

  def self.set_table_name(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name
  end

  def self.all
    row_objs = []
    DBConnection.execute("SELECT * FROM #{self.table_name}").each do |row|
     row_objs << self.new(row)
    end
    row_objs
  end

  def self.find(id)
    self.new(DBConnection.execute("SELECT * FROM #{self.table_name} WHERE" + \
    " id = ? LIMIT 1", id)[0])
  end



  def save
    if self.id.nil?
      create
    else
      update
    end
  end

  def attribute_values
  end

  private

  def create
    sql_string = "INSERT INTO #{self.class.table_name} "
    attrs_without_id = self.class.attributes.dup
    attrs_without_id.delete(:id)
    sql_string += "(" + attrs_without_id * ", " + ") "
    value_array = attrs_without_id.map do |attribute|
       self.send(attribute)
     end
    sql_string += "VALUES (" + (["?"] * (attrs_without_id.count)) * ", "\
     + ")"
    DBConnection.execute(sql_string, *value_array)


    #get row id
    row_id_sql = "SELECT id FROM #{self.class.table_name} WHERE "
    row_id_sql += attrs_without_id.
    map{ |attrib| attrib.to_s + " = ?" } * " AND "
    row_id_sql += " LIMIT 1"

    db_id = DBConnection.last_insert_row_id

    self.id = db_id
  end

  def update
    attrs_without_id = self.class.attributes.dup
    attrs_without_id.delete(:id)

    value_array = attrs_without_id.map do |attribute|
       self.send(attribute)
    end

    DBConnection.execute("UPDATE  #{self.class.table_name} SET " + \
    self.class.attributes.map{ |attrib| attrib.to_s + " = ?"  } * \
    ", " + "WHERE id = ?", *value_array, self.id)
  end
end
