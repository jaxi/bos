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

    def mini_statement_page
      @mini_statement_page ||= begin
        mini_link = user_session.at("a[id='lstAccLst:0:lstOptions:lkMiniAccountStmt']")
        mini_link = / {ajaxURI:'([\S]+)'}/.match(mini_link.attributes["class"].value)[1]
        BOS.agent.get mini_link
      end
    end

    def mini_statement
      @mini_statement ||= begin
        rows = mini_statement_page.search('//table/tbody/tr')
        result = []
        rows.each_with_index do |row, index|
          date_ele = row.at('td[1]/span/text()')
          date = date_ele ? Date.parse(date_ele.text) : result[index - 1][:date]

          description = row.at('td[2]/text()').text.strip

          income = row.at('td[3]/text()')
          income = income ? income.text.strip.to_f : 0

          outcome = row.at('td[4]/text()')
          outcome = outcome ? outcome.text.strip.to_f : 0

          result << {
            date: date,
            description: description,
            income: income,
            outcome: outcome
          }
        end

        result
      end
    end

    def full_statement
      @full_statement ||= begin
        rows = full_statement_page.search('//table/tbody/tr')
        result = []
        rows.each do |row|
          date = Date.parse(row.at("th/span/text()"))
          tds = row.search("td")

          description = tds[0].text.strip
          type = tds[1].text.strip
          income = tds[2].text.to_f
          outcome = tds[3].text.to_f
          balance = tds[4].text

          result << {
            date: date,
            description: description,
            type: type,
            income: income,
            outcome: outcome,
            balance: balance
          }
        end

        result
      end
    end

    def full_statement_page
      @full_statement_page ||= begin
        full_statement_page_link = mini_statement_page
          .at("a[id='miniaccountstatements:lkViewFullStatement']")["href"]

        BOS.agent.get(full_statement_page_link)
      end
    end

    # TODO: Implement query search
    def transaction_query(query, start_date, end_date)
      raise NoMethodError, "transaction_query method will come soon"
    end

    def inspect
      "#<BOS::User:0x#{(object_id << 1).to_s(16)}>"
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
