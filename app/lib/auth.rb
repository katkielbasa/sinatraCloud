require 'sinatra/base'
require 'openssl'
require 'securerandom'
require 'jwt'

# Top-level module
module Sinatra
  # Auth helpers module
  module AuthHelpers
    def password_hash(password, salt=nil)
      digest = OpenSSL::Digest.new('sha1')
      s = salt || SecureRandom.hex
      hmac = OpenSSL::HMAC.hexdigest(digest, s, password)
      { hash: hmac, salt: s }
    end

    def app_hmac_secret
      'SecretSecret123456'
    end

    def jwt_token(payload)
      s = app_hmac_secret
      JWT.encode(payload, app_hmac_secret, 'HS256')
    end

    def jwt_payload(jwt_token)
      s = app_hmac_secret
      puts "Decoding the token. App secret is #{s}"
      JWT.decode(jwt_token, s, true, { algorithm: 'HS256' })
    rescue JWT::VerificationError => e
      puts "Error decoding JWT: #{e}"
      nil
    rescue JWT::DecodeError => e
      puts "Error decoding JWT: #{e}"
      nil
    end

    def logged_in?(cookies)
      decrypted_token = jwt_payload(cookies[:auth_token])
      decrypted_token && decrypted_token.first['username']
    end

    def admin?(cookies)
      decrypted_token = jwt_payload(cookies[:auth_token])
      decrypted_token && decrypted_token.first['admin']
    end
  end

  helpers AuthHelpers
end
