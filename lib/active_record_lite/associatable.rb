require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'
require 'debugger'
class AssocParams
  def other_class
    @other_class_name.constantize
  end

  def other_table
    self.other_class.table_name
  end
end

class BelongsToAssocParams < AssocParams
  attr_reader :primary_key, :foreign_key
  def initialize(name, params)
    @other_class_name = params[:class_name] || name.to_s.camelize
    @primary_key = params[:primary_key] || :id
    @foreign_key = params[:foreign_key] || "#{name}_id".to_sym
  end

  def type
  end
end

class HasManyAssocParams < AssocParams
  attr_reader :other_class_name
  attr_reader :other_table_name, :primary_key, :foreign_key
  def initialize(name, params)
    @other_class_name = params[:class_name] || name.to_s.singularize.camelize
    @primary_key = params[:primary_key] || :id
    @foreign_key = params[:foreign_key] ||
    "#{self.class.to_s.underscore_id}".to_sym
  end

  def type
  end
end

module Associatable
  def assoc_params
    @assoc_params || @assoc_params = {}
  end

  def belongs_to(name, params = {})
    # self -> class
    ap = self.assoc_params
    ap[name] = BelongsToAssocParams.new(name,params)
    aparams = BelongsToAssocParams.new(name, params)
    self.send(:define_method, name) do
      # self -> instance

      my_sql = <<-SQL
      SELECT "#{aparams.other_table}".* FROM #{aparams.other_table}
      INNER JOIN "#{self.class.table_name}"
      ON "#{self.class.table_name}".#{aparams.foreign_key}
      = "#{aparams.other_table}".#{aparams.primary_key};
      SQL
      row = DBConnection.execute(my_sql)
      aparams.other_class.parse_all(row)
    end
  end

  def has_many(name, params = {})
    ap = self.assoc_params
    ap[name] = HasManyAssocParams.new(name, params)
    aparams = HasManyAssocParams.new(name, params)
    self.send(:define_method, name) do

      row = DBConnection.execute(<<-SQL)
      SELECT "#{aparams.other_table}".* FROM #{aparams.other_table}
      INNER JOIN #{self.class.table_name}
      ON #{aparams.other_table}.#{aparams.foreign_key}
      = #{self.class.table_name}.#{aparams.primary_key};
      SQL
      aparams.other_class.parse_all(row)
    end
  end

  def has_one_through(name, assoc1, assoc2)
    assoc1_pa = assoc_params[assoc1]
    self.send(:define_method, name) do

      assoc2_pa = assoc1_pa.other_class.assoc_params[assoc2]

      sql_query = <<-SQL
      SELECT "#{assoc2_pa.other_class.table_name}".*
      FROM #{assoc2_pa.other_class.table_name}
      JOIN #{assoc1_pa.other_class.table_name}
      ON #{assoc2_pa.other_class.table_name}.#{assoc2_pa.primary_key}
      = #{assoc1_pa.other_class.table_name}.#{assoc2_pa.foreign_key}
      SQL
      row = DBConnection.execute(sql_query)
      assoc2_pa.other_class.parse_all(row)
    end
  end
end
