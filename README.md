## HTAuth

* [Homepage](http://copiousfreetime.rubyforge.org/htauth)
* [Github](http://github.com/copiousfreetime/htauth/tree/master)
* email jeremy at copiousfreetime dot org

## DESCRIPTION

HTAuth is a pure ruby replacement for the Apache support programs htdigest and
htpasswd.  Command line and API access are provided for access to htdigest and
htpasswd files.

## FEATURES

HTAuth provides to drop in commands *htdigest-ruby* and *htpasswd-ruby* that
can manipulate the digest and passwd files in the same manner as Apache's
original commands.

*htdigest-ruby* and *htpasswd-ruby* are command line compatible with *htdigest*
and *htpasswd*.  They support the same exact same command line options as the
originals, and have some extras.

Additionally, you can access all the functionality of *htdigest-ruby* and
*htpasswd-ruby* through an API.

## SYNOPSIS

### htpasswd-ruby command line application


    Usage:
    htpasswd-ruby [-cmdpsD] passwordfile username
    htpasswd-ruby -b[cmdpsD] passwordfile username password

    htpasswd-ruby -n[mdps] username
    htpasswd-ruby -nb[mdps] username password

    -b, --batch                      Batch mode, get the password from the command line, rather than prompt
    -c, --create                     Create a new file; this overwrites an existing file.
    -d, --crypt                      Force CRYPT encryption of the password (default).
    -D, --delete                     Delete the specified user.
    -h, --help                       Display this help.
    -m, --md5                        Force MD5 encryption of the password (default on Windows).
    -n, --stdout                     Do not update the file; Display the results on stdout instead.
    -p, --plaintext                  Do not encrypt the password (plaintext).
    -s, --sha1                       Force SHA encryption of the password.
    -v, --version                    Show version info.

### htdigest-ruby command line application

    Usage: htdigest-ruby [options] passwordfile realm username
    -c, --create                     Create a new digest password file; this overwrites an existing file.
    -D, --delete                     Delete the specified user.
    -h, --help                       Display this help.
    -v, --version                    Show version info.

### API Usage

    HTAuth::DigestFile.open("some.htdigest") do |df|
      df.add_or_update('someuser', 'myrealm', 'a password')
      df.delete('someolduser', 'myotherrealm')
    end

    HTAuth::PasswdFile.open("some.htpasswd", HTAuth::File::CREATE) do |pf|
      pf.add('someuser', 'a password', 'md5')
      pf.add('someotheruser', 'a different password', 'sha1')
    end

## CREDITS

* [The Apache Software Foundation](http://www.apache.org/)
* all the folks who contributed to htdigest and htpassword

## LICENSE

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
