module BOS
  class Query
    def initialize(session)
      @session = session
    end

    def balance
      @balance ||= session.at("p[class='balance']/span[2]").text
    end

    def sort_code
      @sort_code ||= begin
        txt = session.at("p[class='numbers wider']").text
        /\d\d-\d\d-\d\d/.match(txt)[0]
      end
    end

    def account_number
      @account_number ||= begin
        txt = session.at("p[class='numbers wider']").text
        /\d{8}/.match(txt)[0]
      end
    end

    def mini_statement_page
      @mini_statement_page ||= begin
        mini_link = session.at("a[id='lstAccLst:0:lstOptions:lkMiniAccountStmt']")
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

    private

    attr_reader :session
  end
end
