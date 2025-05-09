require_relative '../db/db' 
require_relative '../accounts/accounts'

require 'securerandom'

class Licenses
  attr_reader :user_id, :db, :token

  # Initializes the Licenses class with a user token.
  # @param [String] token The authentication token.
  # @return [void]
  def initialize(token)
    @db = Database.new
    acc = Accounts.new
    @token = token
    if acc.auth_token(token) == :VALID then
      @user_id = db.execute('SELECT id FROM Authentication WHERE cookie = ?', [token]).first['id']
      print("[LICENSE_MANAGER] User ID has been set to #{@user_id}\n")
    end
  end

  # Retrieves all licenses associated with the user.
  # @return [Array<Hash>, nil] A list of licenses or nil if no user ID is set.
  def get_licenses
    return nil unless @user_id

    licenses = @db.execute('SELECT * FROM Licenses WHERE owner = ?', [@user_id])

    licenses.map do |license|
      {
        id: license['id'],
        owner: license['owner'],
        license: license['license'],
        product: license['product'],
        expiration: license['expiration']
      }
    end

    return licenses
  end

  # Deletes a license for the user.
  # @param [Integer] id The ID of the license to delete.
  # @return [Boolean] True if the license was deleted, false otherwise.
  def delete_license(id)
    return nil unless @user_id

    id = id.to_i

    license = @db.execute('SELECT * FROM Licenses WHERE id = ? AND owner = ?', [id, @user_id]).first
    unless license
      print("[LICENSE_MANAGER] License with ID #{id} not found or does not belong to the user.\n")
      return false
    end

    @db.execute('DELETE FROM Licenses WHERE id = ? AND owner = ?', [id, @user_id])
    print("[LICENSE_MANAGER] License with ID #{id} has been deleted.\n")
    return true
  end

  # Generates new licenses for a product.
  # @param [String] product The product name for which to generate licenses.
  # @param [Integer] amount The number of licenses to generate.
  # @return [Array<Hash>] A list of generated licenses with product and expiration details.
  def generate_licenses(product, amount, expiration_date)
    return nil unless @user_id

    acc = Accounts.new
    if acc.auth_token(@token) == :VALID then
      user_info = acc.get_info(@token)
      if not (user_info['credits'] >= amount) then
        return 
      end
    end

    values = []
    generated_licenses = []
    if not expiration_date then
      expiration_date = (Time.now + (365 * 24 * 60 * 60)).strftime('%Y-%m-%d')
    end
    #expiration_date = (Time.now + (365 * 24 * 60 * 60)).strftime('%Y-%m-%d')

    def generate_license_key
      characters = [('0'..'9'), ('A'..'F')].map(&:to_a).flatten
      key = ''
      4.times do
        key += (0...4).map { characters[rand(characters.length)] }.join
        key += '-' unless key.length >= 19
      end
      key
    end
    amount.times do
      license_key = generate_license_key()
      values << "(#{@user_id}, '#{license_key}', '#{product}', '#{expiration_date}')"
      generated_licenses << {
        license: license_key,
        product: product,
        expiration: expiration_date
      }
    end

    query = "INSERT INTO Licenses (owner, license, product, expiration) VALUES #{values.join(', ')}"
    @db.execute(query, [])

    user_info = acc.get_info(@token)
    @db.execute("UPDATE Authentication SET credits = ? WHERE cookie = ?", [user_info["credits"] - amount, @token])

    print("[LICENSE_MANAGER] Generated #{amount} licenses for product '#{product}'.\n")
    return generated_licenses
  end
end
