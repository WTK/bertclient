# BERT::Client

BERT::Client is a threadsafe BERT-RPC client with support for persistent 
connections and SSL. It currently exposes BERT-RPC's cast and call.
This version is designed to work with *modified* [ernie](https://github.com/mojombo/ernie) server that **doesn't** (as a contrary to regular ernie version) close connection after response.
Tested on ruby 1.9.2.

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

# Available contructor attributes

<table>
    <tr>
        <th>Option</th><th>Default value</th><th>Description</th>
    </tr>
    <tr>
        <td>
            host
        </td>
        <td>
            localhost
        </td>
        <td>
            Hostname of server that ernie server runs on.
        </td>
    </tr>
    <tr>
        <td>
            port
        </td>
        <td>
            9999
        </td>
        <td>
            Port number on which ernie server listens on.
        </td>
    </tr>
    <tr>
        <td>
            timeout
        </td>
        <td>
            15
        </td>
        <td>
            Currently socket doesn't connection doesn't respect this value. TODO: Fix it
        </td>
    </tr>
    <tr>
        <td>
            gzip, gzip_threshold, gzip_accept_sent
        </td>
        <td>
            false, 1024, false
        </td>
        <td>
            [untested] These gzip-encoding related attributes have been introduced in original bertclient. I wasn't able to find any information concerning possible usage of gzip in bert/berp, so I'm not really sure whenever this works and/or is implemented correctly.
        </td>
    </tr>
    <tr>
        <td>
            ssl
        </td>
        <td>
            false
        </td>
        <td>
            TODO
        </td>
    </tr>
    <tr>
        <td>
            verify_ssl
        </td>
        <td>
            true
        </td>
        <td>
            TODO
        </td>
    </tr>
    <tr>
        <td>
            encoding
        </td>
        <td>
            "utf-8"|nil
        </td>
        <td>
            Expected encoding for any string data returned by ernie. For this function working correctly, you have to use version of BERT that supports passing encoding type to decode function.
            There are a lot of forks of BERT that are doing just that, personally I'm using [this one](https://github.com/kenpratt/bert).
            If your BERT library doesn't support passing encoding to decode method, client would fallback to regular one-argument method of BERT.
        </td>
    </tr>
</table>

# TODO

* Write tests
* Package and publish the gem version