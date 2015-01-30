require "bos/version"
require "mechanize"

module BOS
  ENDPOINT = "https://bankofscotland.co.uk".freeze
  LOGIN_PAGE = "https://online.bankofscotland.co.uk/personal/logon/login.jsp".freeze
  class << self
    def agent
      @agent ||= begin
        a = Mechanize.new
        a.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        a
      end
    end

    def login(id, password, security_code)
      login_page = agent.get(LOGIN_PAGE)
      login_form = login_page.form("frmLogin")
      login_form["frmLogin:strCustomerLogin_userID"] = id
      login_form["frmLogin:strCustomerLogin_pwd"] = password

      page = agent.submit(login_form, login_form.buttons.first)

      if page.uri.to_s.include? LOGIN_PAGE
        raise LoginError, "ID OR PASSWORD IS WRONG"
      else
        enter_secure_code(page, security_code)
      end
    end

    def enter_secure_code(page, code)
      secure_code_form = page.form("frmentermemorableinformation1")

      number1 = page.search("label[for='frmentermemorableinformation1:strEnterMemorableInformation_memInfo1']").text()
      number1 = code[/\d+/.match(number1)[0].to_i - 1]

      number2 = page.search("label[for='frmentermemorableinformation1:strEnterMemorableInformation_memInfo2']").text()
      number2 = code[/\d+/.match(number2)[0].to_i - 1]

      number3 = page.search("label[for='frmentermemorableinformation1:strEnterMemorableInformation_memInfo3']").text()
      number3 = code[/\d+/.match(number3)[0].to_i - 1]

      secure_code_form.field_with(name: "frmentermemorableinformation1:strEnterMemorableInformation_memInfo1")
        .value = "&nbsp;#{number1}"
      secure_code_form.field_with(name: "frmentermemorableinformation1:strEnterMemorableInformation_memInfo2")
        .value = "&nbsp;#{number2}"
      secure_code_form.field_with(name: "frmentermemorableinformation1:strEnterMemorableInformation_memInfo3")
        .value = "&nbsp;#{number3}"
      main_page = agent.submit(secure_code_form, secure_code_form.buttons.first)

      raise LoginError, "SECURE CODE IS WRONG" unless /account_overview_personal/.match main_page.uri.to_s

      return main_page
    end
  end

  class LoginError < StandardError; end
end
