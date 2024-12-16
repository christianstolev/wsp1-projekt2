require 'digest'

# This class handles hashing of strings using SHA-2.
class SHA
  # Initializes the SHA class.
  def initialize() end

  # Hashes the given string using SHA-2.
  # @param [String] str The string to hash.
  # @return [String] The SHA-2 hash of the provided string.
  def hash_str(str)
    Digest::SHA2.hexdigest str
  end
end
