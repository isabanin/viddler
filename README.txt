= Viddler.rb

* Rubyforge profile: http://viddler.rubyforge.com
* Source code repository: https://apricode.svn.beanstalkapp.com/gems/trunk/viddler

== DESCRIPTION:

Ruby wrapper around Viddler.com[http://www.viddler.com] API.

== FEATURES:

Currently implemented API methods:

* viddler.videos.getRecordToken
* viddler.users.register
* viddler.users.auth
* viddler.users.getProfile
* viddler.users.setProfile
* viddler.users.setOptions
* viddler.videos.upload
* viddler.videos.getStatus
* viddler.videos.getDetails
* viddler.videos.getDetailsByUrl
* viddler.videos.setDetails
* viddler.videos.getByUser
* viddler.videos.getByTag
* viddler.videos.getFeatured
  
== NOT YET IMPLEMENTED:

* Wrapper for video permissions.
  
== REQUIREMENTS:

* active_support[http://rubyforge.org/projects/activesupport/]
* rest-client[http://rubyforge.org/projects/rest-client/]
* mime-types[http://rubyforge.org/projects/mime-types/]

== INSTALL:

* sudo gem install viddler

== SEND PATCHES:

* Lighthouse[http://ilya_sabanin.lighthouseapp.com/projects/10110-viddler-rb/overview]

== CONTACT:

* ilya dot sabanin at gmail.com

== CONTRIBUTORS:

* Kyle Slattery

== LICENSE:

(The MIT License)

Copyright (c) 2008 Ilya Sabanin

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.