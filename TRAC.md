# TRAC - Bot::BasicBot::Pluggable::Module::Brownian

Issue, to-do, and wish list, tracking file for the Brownian development project.

## ISSUES

 - _(smpb, 25/11/2001)_ Brownian does not parse punctuation on the end of factoids correctly.

## TO-DO

 - _(smpb, 24/11/2011)_ Deprecate this file and move all of this to a proper platform. Say, Github.
 - _(nfn, 25/11/2011)_ Bot::YadaYada::RSS is still spammy as hell on the logs. Fix this.

## WISH LIST

 - _(nfn, 11/05/2012)_ Implement a mechanism to store messages for users who are away.
   Use the "tell X about Y" interface and, if _Y_ is not online, store the message and
   send it to her when she comes back on.

 - _(nfn, 03/04/2012)_ Implement a URL collector module and give people access
   to it via the web.

 - _(nfn, 03/04/2012)_ Add a twitter account to the bot and teach it to tweet
   when we ask it to and also on specific "special" occasions.

 - _(nfn, 30/11/2011)_ Add an alarm/reminders module to the bot.

 - _(smpb, 24/11/2011)_ The bot's very own internal karma meter:
   - He dislikes people that 'botslap' him often
   - He likes people that 'botsnack' him (but not too often!)
   - He "feels" a kinship to those who have taught him more
   - Boilerplate replies (like greetings) should vary according to these metrics
   - _(nfn, 25/11/2011)_ The replies should be modulated by the user's recent 
     interactions in the form of botslaps and botsnacks. In the extreme the bot
     should stop responding to the user after being heavily abused

 - _(nfn, 25/11/2011)_ Implement a 'substitute' module that catches phrases 
   like 's/this/that/' and replies with 'user meant "latest user's phrase with 
   substitution'

 - _(smpb, 25/11/2011)_ Implement NIALL, the Non-Intelligent Artificial 
   Language Learner, within Brownian:
   - More info: http://www.lab6.com/old/niall.html
   - Build upon the basic Perl implementation: http://www.lab6.com/old/niall-perl.html
   - Work on the corpus (which will have a lot of pollution) to provide a more 
     flavourful interaction

 - _(smpb, 25/11/2011)_ Probability associated to replies
   - Brownian should recognize keywords in the middle of sentences (not just 
     the beginning)
   - If the keyword is found on a very active conversation, Brownian's tendency
     to disrupt should be lower
   - Likelihood of reply should be high to someone recently joined or that 
     hasn't spoken in a long time
   - Direct mentions ("brownian: blah") should have a reply rate of 100%

 - _(smpb, 25/11/2011)_ Pipe unrecognized queries to a "magic 8-ball" or an 
   engine powered by NIALL, removing lame stock replies like "Search me, bub."

## SOLVED ISSUES

 - _(smpb, 24/11/2011)_ At every single restart of the bot, the RSS module 
   parses all the feeds again and floods the channel with notifications.
   -- Solved by _(nfn, 25/11/2011)_

 - _(nfn, 25/11/2011)_ Implement a logging module. 
   -- Solved by _(nfn, 23/03/2012)_

 - _(nfn, 25/11/2011)_ Implement a 'backlog' module, allowing people to read 
   the backlog for the last N [minutes|interactions] before they joined the 
   channel. (See logging module) -- Solved by (_nfn, 04/04/2012)_

