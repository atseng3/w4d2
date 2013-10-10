require 'singleton'
require 'oauth'
require 'launchy'
require 'yaml'

class TwitterSession
  include Singleton
  attr_reader :access_token

  CONSUMERKEY	= 'BNPqsaw8ht9ffF5SWSoOA'
  CONSUMERSECRET = 'g9Z8VcnTqpxUCBCjr4IBnZPKuxRswN8zy35f5Chw'

  CONSUMER = OAuth::Consumer.new(
    CONSUMERKEY, CONSUMERSECRET, :site => "https://twitter.com"
  )

  def initialize
    @access_token = read_or_request_access_token
  end

  def self.get(*args)
    self.instance.access_token.get(*args)
  end

  def self.post(*args)
    self.instance.access_token.post(*args)
  end

  protected
    def read_or_request_access_token
      request_token = CONSUMER.get_request_token
      authorize_url = request_token.authorize_url
      puts "Go to this URL: #{authorize_url}"
      Launchy.open(authorize_url)
      puts "Login, and type your verification code in"
      oauth_verifier = gets.chomp
      access_token = request_token.get_access_token( :oauth_verifier => oauth_verifier )
    end
end


