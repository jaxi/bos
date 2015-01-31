module BOS
  class User
    def initialize(user_id, password, security_code)
      @user_id = user_id
      @password = password
      @security_code = security_code
    end

    def user_session
      enter_password
      enter_security_code
      overview_page
    end

    def balance
      @balance ||= user_session.at("p[class='balance']/span[2]").text
    end

    def sort_code
      @sort_code ||= begin
        txt = user_session.at("p[class='numbers wider']").text
        /\d\d-\d\d-\d\d/.match(txt)[0]
      end
    end

    def account_number
      @account_number ||= begin
        txt = user_session.at("p[class='numbers wider']").text
        /\d{8}/.match(txt)[0]
      end
    end

    private

    # Private: Login with the user's id and password
    #
    # Returns: Security Page
    def enter_password
      return if @security_page

      login_page = BOS.agent.get(LOGIN_PAGE)
      login_form = login_page.form("frmLogin")
      login_form["frmLogin:strCustomerLogin_userID"] = user_id
      login_form["frmLogin:strCustomerLogin_pwd"] = password

      page = BOS.agent.submit(login_form, login_form.buttons.first)

      if page.uri.to_s.include? LOGIN_PAGE
        raise LoginError, "ID OR PASSWORD IS WRONG"
      else
        @security_page = page
      end
    end

    # Private: Enter the security code on security information page
    #
    # Returns: Acccount Overall Page
    def enter_security_code
      return if @overview_page
      security_code_form = security_page.form("frmentermemorableinformation1")

      number1 = security_page.search("label[for='frmentermemorableinformation1:strEnterMemorableInformation_memInfo1']").text()
      number1 = security_code[/\d+/.match(number1)[0].to_i - 1]

      number2 = security_page.search("label[for='frmentermemorableinformation1:strEnterMemorableInformation_memInfo2']").text()
      number2 = security_code[/\d+/.match(number2)[0].to_i - 1]

      number3 = security_page.search("label[for='frmentermemorableinformation1:strEnterMemorableInformation_memInfo3']").text()
      number3 = security_code[/\d+/.match(number3)[0].to_i - 1]

      security_code_form.field_with(name: "frmentermemorableinformation1:strEnterMemorableInformation_memInfo1")
        .value = "&nbsp;#{number1}"
      security_code_form.field_with(name: "frmentermemorableinformation1:strEnterMemorableInformation_memInfo2")
        .value = "&nbsp;#{number2}"
      security_code_form.field_with(name: "frmentermemorableinformation1:strEnterMemorableInformation_memInfo3")
        .value = "&nbsp;#{number3}"

      page = BOS.agent.submit(security_code_form, security_code_form.buttons.first)

      if /account_overview_personal/.match page.uri.to_s
        @overview_page = page
      else
        raise LoginError, "SECURE CODE IS WRONG" unless /account_overview_personal/.match page.uri.to_s
      end
    end

    attr_reader :user_id, :password, :security_code

    attr_reader :security_page, :overview_page
  end
end
