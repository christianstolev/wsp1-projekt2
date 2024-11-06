require 'digest'

class SHA
    def initialize() end

    def hash_str(str)
        Digest::SHA2.hexdigest str
    end
end