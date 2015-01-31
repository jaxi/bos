# BOS

BOS is a ruby client that scrape your banking details from your bank of scotland web page. You are higly under risk (e.g. online bank account get blocked; Either password or security code leaks) when using it. So please do use it responsibly (The author of the gem under any circumstances will not responsible for any lost ```BOS``` causes).

It seems like Lloyds Bank plc, TSB Bank plc, Bank of Scotland plc and Halifax, as all of them belong to Lloyds Banking Group, are sharing the same banking system. As a result, you might be able to migrate the gem to some other banking systems without too much difficulties. Again, please do use it responsibly!

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bos'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bos

## Usage

BOS is a screen scraper that collect you your banking details.

If you use it for the first time, then you need do configuration. The code shown below would store your banking details into ~/.bos file and persit in JSON format.

```ruby
BOS.confg USER_ID, PASSWORD, SECURITY_CODE
```

The code snippet below show the basic usage of BOS gem (very easy to understand, isn't it?)

```ruby
client = BOS.client # Return a bos client.

client.balance
client.account_number
client.sort_code
client.mini_statement
client.full_statement
```


## Contributing

1. Fork it ( https://github.com/jaxi/bos/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
