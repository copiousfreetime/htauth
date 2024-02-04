## HTAuth

[![Build Status](https://copiousfreetime.semaphoreci.com/badges/htauth/branches/main.svg)](https://copiousfreetime.semaphoreci.com/projects/htauth)

* [Homepage](http://github.com/copiousfreetime/htauth)
* [Github](http://github.com/copiousfreetime/htauth)

## DESCRIPTION

HTAuth provides an API, and commandline tools for managing Apache/httpd style
htpasswd and htdigest files.

## FEATURES

HTAuth provides an API allowing direct manipulation of Apache/httpd style
`htdigest` and `htpasswd` files. Supporting full programtaic manipulation and
authentication of user credentials.

HTAuth also includes drop-in, commandline compatible replacements for the Apache
utilities `htpasswd` and `htdigest` with the respective `htpasswd-ruby` and
`htdigest-ruby` commands.

Additonally, support for the [argon2](https://github.com/technion/ruby-argon2)
password hashing algorithm is provided for most platforms.

## SYNOPSIS

### API Usage

    HTAuth::DigestFile.open("some.htdigest") do |df|
      df.add_or_update('someuser', 'myrealm', 'a password')
      df.delete('someolduser', 'myotherrealm')
    end

    HTAuth::PasswdFile.open("some.htpasswd", HTAuth::File::CREATE) do |pf|
      pf.add('someuser', 'a password', 'md5')
      pf.add('someotheruser', 'a different password', 'sha1')
    end

    HTAuth::PasswdFile.open("some.htpasswd", HTAuth::File::ALTER) do |pf|
      pf.update('someuser', 'a password', 'bcrypt')
    end

    HTAuth::PasswdFile.open("some.htpasswd") do |pf|
      pf.authenticated?('someuser', 'a password')
    end


### htpasswd-ruby command line application

    Usage:
            htpasswd-ruby [-cimBdpsD] [-C cost] passwordfile username
            htpasswd-ruby -b[cmBdpsD] [-C cost] passwordfile username password

            htpasswd-ruby -n[imBdps] [-C cost] username
            htpasswd-ruby -nb[mBdps] [-C cost] username password

            --argon2     Force argon2 encryption of the password.
        -b, --batch      Batch mode, get the password from the command line, rather than prompt.
        -B, --bcrypt     Force bcrypt encryption of the password.
        -C, --cost COST  Set the computing time used for the bcrypt algorithm
                         (higher is more secure but slower, default: 5, valid: 4 to 31).
        -c, --create     Create a new file; this overwrites an existing file.
        -d, --crypt      Force CRYPT encryption of the password.
        -D, --delete     Delete the specified user.
        -h, --help       Display this help.
        -i, --stdin      Read the passwod from stdin without verivication (for script usage).
        -m, --md5        Force MD5 encryption of the password (default).
        -n, --stdout     Do not update the file; Display the results on stdout instead.
        -p, --plaintext  Do not encrypt the password (plaintext).
        -s, --sha1       Force SHA encryption of the password.
        -v, --version    Show version info.
            --verify     Verify password for the specified user.

### htdigest-ruby command line application

    Usage: htdigest-ruby [options] passwordfile realm username
        -c, --create   Create a new digest password file; this overwrites an existing file.
        -D, --delete   Delete the specified user.
        -h, --help     Display this help.
        -v, --version  Show version info.

## Supported Hash Algorithms

Out of the box, `htauth` supports the classic algorithms that ship with Apache
`htpasswd`.

- Built in
    - Generally accepted
        - MD5 (default for compatibilty reasons)
        - bcrypt (probably the better choice)

    - **Not Recommended** - available only for backwards compatibility with `htpasswd`
        - SHA1
        - crypt
        - plaintext

- Available with the installation of additional libraries:
    - argon2 - to use, add `gem 'argon2'` to your `Gemfile`. `argon2` will
      now be a valid algorithm to use in `HTAuth::PasswdFile` API. Currently
      argon2 is not supported on windows as the upstream `argon2` gem does not
      support windows.

## CREDITS

* [The Apache Software Foundation](http://www.apache.org/)
* all the folks who contributed to htdigest and htpassword

## MIT LICENSE

Copyright (c) 2008 Jeremy Hinegardner

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
