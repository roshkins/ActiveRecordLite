require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

class AssocParams
  def other_class
  end

  def other_table
  end
end

class BelongsToAssocParams < AssocParams
  def initialize(name, params)
  end

  def type
  end
end

class HasManyAssocParams < AssocParams
  def initialize(name, params, self_class)
  end

  def type
  end
end

module Associatable
  def assoc_params
  end

  def belongs_to(name, params = {})
    # self -> class
    self.send(:define_method, name) do
      # self -> instance
      other_class_name = params[:class_name] || name.camelize
      primary_key = params[:primary_key] || :id
      foreign_key = params[:foreign_key] || "#{name}_id".to_sym
      other_class = other_class_name.constantize
      other_table_name = other_class.table_name

      row = DBConnection.execute(<<-SQL)
      SELECT "#{other_table_name}".* FROM #{other_table_name}
      INNER JOIN #{self.class.table_name}
      ON #{self.class.table_name}.#{foreign_key}
      = #{other_table_name}.#{primary_key};
      SQL
      other_class.parse_all(row)
    end
  end

  def has_many(name, params = {})
    self.send(:define_method, name) do

    end
  end

  def has_one_through(name, assoc1, assoc2)
  end
end
