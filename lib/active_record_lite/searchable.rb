require_relative './db_connection'

module Searchable
  def where(params)
    where_clause = params.keys.map { |key| "#{key} = ?" }
    sql_query = "SELECT * FROM #{self.table_name}"
    sql_query += " WHERE " + where_clause * " AND "
    ret_obj = []
    self.parse_all(DBConnection.execute(sql_query, *params.values))
  end
end