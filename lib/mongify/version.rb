require 'net/ssh/version'

module Mongify

  # Describes the current version of Mongify.
  class Version < Net::SSH::Version
    MAJOR = 0
    MINOR = 0
    TINY  = 1

    # The current version, as a Version instance
    CURRENT = new(MAJOR, MINOR, TINY)

    # The current version, as a String instance
    STRING  = CURRENT.to_s
  end

end
