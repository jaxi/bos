require "bos/version"
require "mechanize"

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
  end

  class LoginError < StandardError; end
end

require "user"
