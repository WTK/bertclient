# BERT::Client

BERT::Client is a threadsafe BERT-RPC client with support for persistent 
connections and SSL. It currently exposes BERT-RPC's cast and call.
Initially designed to work with *modified* [ernie](https://github.com/mojombo/ernie) server that doesn't close connection after response.
Tested on ruby 1.9.2

# Dependancies

Requires [BERT](https://github.com/mojombo/bert) gem to be installed.

Requires Jeweler gem to be installed if you want to pack this library into it's own gem.

# Usage

    require 'bertclient'
    client = BERT::Client.new(:host => 'localhost', :port => 9999)
    client.call(:calc, :add, 1, 2)
    #=> 3
    client.call(:calc, :add, 5, 5)
    #=> 10
    client.call(:calc, :sub, 10, 5)
    #=> 5

You can also use blocks to create ephemeral connections:

    BERT::Client.new(opts) do |client|
      client.call(:auth, :authenticate, user, password)
      client.call(:calc, :add, 1, 2)
    end

# TODO

* Write some tests
* Package and publish the gem version