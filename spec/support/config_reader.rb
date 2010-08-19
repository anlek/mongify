class ConfigReader
  def initialize(filepath)
    if File.exists?(filepath)
      config = YAML.load_file(filepath)
      #puts ">>> READING #{filepath}"
      config.each { |key, value| instance_variable_set("@#{key}", value) }
    else
      raise ">>> Can't find #{filepath} -- unable to read config file <<<"
    end
  end
  
  def responses_to?(key)
    instance_variable_get("@#{key}") ? instance_variable_get("@#{key}") : super(key)
  end
  
  def method_missing(meth, *args, &blk)
    value = instance_variable_get("@#{meth}")
    return value if value
    super(meth, args, blk)
  end
end