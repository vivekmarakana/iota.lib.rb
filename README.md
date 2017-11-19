# IOTA Ruby Gem

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/vivekmarakana/iota.lib.rb/master/LICENSE)

This is the **unofficial** Ruby gem for the IOTA Core. It implements both the [official API](https://iota.readme.io/), as well as newly proposed functionality (such as signing, bundles, utilities and conversion).

This gem is a **beta release**. If you find any bug or face issue, please [post it here](https://github.com/vivekmarakana/iota.lib.rb/issues).

**Note: This release does not have multi signature support. It will be added after successful testing of this version**

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'iota-ruby', github: 'vivekmarakana/iota.lib.rb', branch: 'master', require: 'iota'
```

And then execute:

    $ bundle


# Documentation

You can find basic documentation at: [https://vivekmarakana.gitbooks.io/iota-ruby](https://vivekmarakana.gitbooks.io/iota-ruby/)


## Getting Started

After you've successfully installed the library, it is fairly easy to get started by simply launching a new instance of the IOTA object with an optional settings object. When instantiating the object you have the option to decide the API provider that is used to send the requests to and you can also connect directly to the Sandbox environment.

The optional settings object can have the following values:

1. **`host`**: `String` Host you want to connect to. Can be DNS, IPv4 or IPv6. Defaults to `localhost `
2. **`port`**: `Int` port of the host you want to connect to. Defaults to 14265.
3. **`provider`**: `String` If you don't provide host and port, you can supply the full provider value to connect to
4. **`sandbox`**: `Bool` Optional value to determine if your provider is the IOTA Sandbox or not.
5. **`token`**: `String` Token string in case you are using sandbox.

You can either supply the remote node directly via the `provider` option, or individually with `host` and `port`, as can be seen in the example below:

```ruby
# Create client with host and port as provider
client = IOTA::Client.new(host: 'http://localhost', port: 14265)

# Create client directly with provider
client = IOTA::Client.new(provider: 'http://localhost:14265')

# now you can start using all of the functions
status, data = client.api.getNodeInfo
```

Overall, there are currently four subclasses that are accessible from the IOTA object:
- **`api`**: Core API functionality for interacting with the IOTA core.
- **`utils`**: Utility related functions for conversions, validation and so on
- **`validator`**: Validator functions that can help with determining whether the inputs or results that you get are valid.
- **`multisig`**: *In progress*


## How to use the Library

All API calls are executed **synchronously** and returns array with 2 entries. First entry is `status` and second is `data`. However, you can use it by passing block to it as well.

Here is a simple example of how to access the `getNodeInfo` function:

```ruby
# Method 1
client.api.getNodeInfo do |status, data|
  if !status
    # If status is `false`, `data` contains error message...
    puts data
  else
    # If status is `true`, `data` contains response...
    puts data.inspect
  end
end

# Method 2
status, data = client.api.getNodeInfo
if !status
  puts data
else
  puts data.inspect
end
```

If you'd like to support development, please consider donating to my IOTA address: **YPQDEJCJFRXVPGZKVLZFTGQYWEFSPLYEA9STGEVGDJDCVYCMGEZAJQRPVXFXQQRTKQRKROSHSFPSLHNP9UQFCKKGTZ**
