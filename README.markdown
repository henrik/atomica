# AtomICA

Ruby Sinatra app that provides an Atom feed of your ICA-banken account activity.
ICA-banken is a Swedish bank.

Provide personnummer and PIN with either regular params (e.g. for Feedly):

    https://atomica.herokuapp.com/feed?pnr=7512301234&pwd=9876

Or with HTTP Basic authentication:

    https://7512301234:9876@atomica.herokuapp.com/feed

You may want to make sure you or your RSS reader app don't share the feed URL or contents.

I suggest you set up your own instance on Heroku, as you don't know if someone else's will do something evil with your authentication details.

To debug, you can run AtomICA on the command line:

    ruby ica.rb 7512301234 9876

Note that if you log in with the wrong PIN three times in a row, ICA may lock your account.


## TODO

 * Caching (careful so HTTP auth doesn't cause conflation)
 * Configure Heroku to filter logs


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
