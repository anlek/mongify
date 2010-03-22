module Mongify
  class Config
    class << self
      attr_accessor :in_stream, :out_stream, :file_path
    end
  end
end