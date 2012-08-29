Malcolm
=======

@ Anand Gupta, 2012

About
-----

Malcolm is an XMPP/Google Talk bot that maintains a chatroom. 
All this means is that any user who messages malcolm will have his/her
message broadcast to other users in the chatroom. Malcolm will send messages
to users even if they are offline.

Google talk doesn't natively provide long-lived chatrooms, which are very handy
for teams or groups of friends who need to stay in touch. You use a Malcolm 
chatroom just as you would IRC, except it's integrated into the widely-used Google talk 
infrastructure. 

Malcolm comes with a few conveniences built in, such as URL shortening and gist-ification

Url shortening is automatic, making use of bit.ly, but you can easily disable it. 

To create gists from long messages, simply prefix your message with 
> malcolm gist [messagebody]

Malcolm supports a few other directives, such as

* User listing, just ask:
> Malcolm who's here?

* Nicknames:
> Malcolm, my name is [name]

* User access:
> Malcolm, allow [username@domain]

None of malcolm's directives are case or punctuation sensitive. 

Install 
-------

Malcolm uses bundler to get his deps. 
Use 'bundle install' to set things up

You'll need to provide gtalk credentials for Malcolm:

Fill in 
> botUsername = ''

and

> botPassword = ''

in bot/mcore.rb

You'll also need a Bitly API key to allow for URL shortening, which you can fill in
> bitlyUsername = ''

and

> bitlyApikey   = ''

in bot/mcore.rb

Optional: You can provide your Github credentials to associate gists with your account
> gistUsername = ''

> gistPassword = ''

in bot/mcore.rb

If you want, you can restrict access to malcolm by providing a whitelist of users. 
> allowed = ['user@domain', 'user2@domain']

By default, malcolm will allow any user who subscribes to join the chat
> allowed = nil

in bot/mcore.rb

You can customise malcolm's behavior in malcolm.rb

Run
---

Just execute run.sh

If you peek inside run.sh, you'll see that all it does is bundle exec, making
Malcolm something perfectly suitable for use on Heroku. 

Related
-------

https://github.com/spartango/Anne-bot
A bot that gives you access to asana from Malcolm

https://github.com/spartango/Pepper-bot
A bot that gives you access to posterous from Malcolm

https://github.com/spartango/ToXmpp
A script that sends text from the commandline to Malcolm

