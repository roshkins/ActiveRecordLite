class MassObject
  def self.set_attrs(*attributes)
    attributes.each do |attribute|
      attr_accessor attribute
    end
    @attributes = attributes
  end

  def self.attributes
    @attributes
  end

  def self.parse_all(results)
    ret_obj = []
    results.each do |row|
      ret_obj << self.new(row)
    end
    ret_obj
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      attr_name = attr_name.to_sym
      if self.class.attributes.include?(attr_name)
        send("#{attr_name}=", value)
      else
        raise "mass assignment to unregistered attribute #{attr_name}"
      end
    end
  end
end
