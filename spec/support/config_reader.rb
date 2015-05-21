# Used during testing to read in a config file
class ConfigReader
  def initialize(filepath)
    if File.exists?(filepath)
      config = YAML.load_file(filepath)
      config.each { |key, value| instance_variable_set("@#{key}", value) }
    else
      raise ">>> Can't find #{filepath} -- unable to read config file <<<"
    end
  end

  # Return true if there is an instance variable under that name
  def responses_to?(key)
    instance_variable_get("@#{key}") ? instance_variable_get("@#{key}") : super(key)
  end

  # Returns value of instance variable if set
  def method_missing(meth, *args, &blk)
    value = instance_variable_get("@#{meth}")
    return value if value
    super(meth, args, blk)
  end
end