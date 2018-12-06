# IOTA Ruby Gem

[![Build Status](https://travis-ci.org/vivekmarakana/iota.lib.rb.svg?branch=master)](https://travis-ci.org/vivekmarakana/iota.lib.rb) [![Gem Version](https://badge.fury.io/rb/iota-ruby.svg)](https://badge.fury.io/rb/iota-ruby) [![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/vivekmarakana/iota.lib.rb/master/LICENSE)

This is the **unofficial** Ruby gem for the IOTA Core. It implements both the [official API](https://iota.readme.io/), as well as newly proposed functionality (such as signing, bundles, utilities, conversion, multi signature support and reattch/promote).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'iota-ruby'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install iota-ruby


# Documentation

You can find basic documentation at: [https://vivekmarakana.gitbooks.io/iota-ruby](https://vivekmarakana.gitbooks.io/iota-ruby/)


## Getting Started

After you've successfully installed the library, it is fairly easy to get started by simply launching a new instance of the IOTA object with an optional settings object. When instantiating the object you have the option to decide the API provider that is used to send the requests to and you can also connect directly to the Sandbox environment.

The optional settings object can have the following values:

1. **`host`**: `String` Host you want to connect to. Can be DNS, IPv4 or IPv6. Defaults to `localhost `
2. **`port`**: `Integer` port of the host you want to connect to. Defaults to 14265.
2. **`user`**: `String` username for host if required.
2. **`password`**: `String` password for host if required.
3. **`provider`**: `String` If you don't provide host and port, you can supply the full provider value to connect to
4. **`sandbox`**: `Boolean` Optional value to determine if your provider is the IOTA Sandbox or not.
5. **`token`**: `String` Token string in case you are using sandbox.
5. **`timeout`**: `Integer` Timeout in seconds for api requests to full node. Defaults to 120.
5. **`batch_size`**: `Integer` Batch size for apis like `getTrytes`, `getBalances` etc. Defaults to 500.
5. **`local_pow`**: `Boolean` Should PoW be done local machine or not. Defaults to `false` i.e. remote PoW.

You can either supply the remote node directly via the `provider` option, or individually with `host` and `port`, as can be seen in the example below:

```ruby
require 'iota'

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
- **`multisig`**: Functions for creating and signing multi-signature addresses and transactions.


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

## Local PoW Support

If you want to use this gem with public full node which does not support remote PoW on host, you can set `local_pow` to `true` when initialising the client.

```ruby
require 'iota'

# With remote PoW
client = IOTA::Client.new(provider: 'https://node.iota-tangle.io:14265')
# If you use `client.api.attachToTangle` api here, you'll get error saying that attachToTangle command is not allowed

# With local pow
client = IOTA::Client.new(provider: 'https://node.iota-tangle.io:14265', local_pow: true)
# Now you can use `client.api.attachToTangle` api, which will do the proof-of-work on transaction and return the trytes that needs to be broadcasted
```

## Compatibility

Tested on [Travis CI](https://travis-ci.org/vivekmarakana/iota.lib.rb) on following environment [configurations](https://github.com/vivekmarakana/iota.lib.rb/blob/master/.travis.yml):

- ruby-head (Linux)
- 2.5.1 (Linux & Mac)
- 2.4.1 (Linux & Mac)
- jruby-head (OpenJDK8/Linux)
- jruby-19mode (OpenJDK8/Linux & OpenJDK8/OSX)
- jruby-18mode (OpenJDK8/Linux & OpenJDK8/OSX)
- rbx-3 (Linux)
