require "bos/version"
require "mechanize"

require "user"
require "json"

module BOS
  LOGIN_PAGE = "https://online.bankofscotland.co.uk/personal/logon/login.jsp".freeze
  class << self
    def agent
      @agent ||= begin
        a = Mechanize.new
        a.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        a
      end
    end

    # Public: Configure the user_id, password and security code
    #
    # Return: Nothing
    def config(options = {})
      if options[:file]
        filename = options[:filename] || File.join(Dir.home, ".bos")
        config_hash = JSON.parse(IO.read(filename), symbolize_names: true)
        @user_id = config_hash[:user_id]
        @password = config_hash[:password]
        @security_code = config_hash[:security_code]
      else
        @user_id = options[:user_id]
        @password = options[:password]
        @security_code = options[:security_code]
        File.open(File.join(Dir.home, ".bos"), "w") do |f|
          f.write options.to_json
        end
      end
    end

    # Public: The client that answer your questions about your banking
    #
    # Returns: A BOS::User object
    def client
      @client ||= begin
        config(file: true) if !user_id
        User.new(user_id, password, security_code)
      end
    end

    private
    attr_reader :user_id, :password, :security_code
  end

  class LoginError < StandardError; end
end
