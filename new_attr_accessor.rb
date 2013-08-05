class Object

  def self.new_attr_accessor(*syms)
    syms.each do |method_name|
      define_method("#{method_name}") do
        instance_variable_get("@#{method_name}")
      end

      define_method("#{method_name}=") do |val|
        instance_variable_set("@#{method_name}", val)
      end
    end
  end

end
