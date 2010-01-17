# AtomICA

Ruby CGI script that uses `mechanize` and `Builder` to provide an Atom feed of
your ICA-banken account activity. ICA-banken is a Swedish bank.

Shows activity from the last 14 days across all accounts under the same login.

Uses HTTP Basic authentication (personnummer as username, PIN as password) as
some web-based feed readers (like Bloglines) will otherwise not consider the
feed fully private. The feed URL will be something like this:

    http://7512301234:9876@example.com/feeds/ica.atom

HTTP Basic is plaintext. You should trust the connection between your client and
the server. Also, make sure you don't share the feed if you use a web-based reader.

The script can take params instead of HTTP Basic to work with e.g. Google Reader:

    http://example.com/feeds/ica.atom?pnr=7512301234&pwd=9876
    
Make sure you don't share the feed.

For your own privacy, I will not offer a hosted version.

To debug, you can run it on the command line:

    ruby ica.cgi 7512301234 9876


## Example screenshot

Example screenshot with fake data in [NetNewsWire](http://www.newsgator.com/INDIVIDUALS/NETNEWSWIRE/):

![Screenshot](http://henrik.nyh.se/uploads/atomica.png)


## TODO

 * Graceful error handling if auth details are wrong
 * Graceful error handling if scraping fails


## Credits and license

By [Henrik Nyh](http://henrik.nyh.se/) under the MIT license:

>  Copyright (c) 2008 Henrik Nyh
>
>  Permission is hereby granted, free of charge, to any person obtaining a copy
>  of this software and associated documentation files (the "Software"), to deal
>  in the Software without restriction, including without limitation the rights
>  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
>  copies of the Software, and to permit persons to whom the Software is
>  furnished to do so, subject to the following conditions:
>
>  The above copyright notice and this permission notice shall be included in
>  all copies or substantial portions of the Software.
>
>  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
>  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
>  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
>  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
>  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
>  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
>  THE SOFTWARE.
