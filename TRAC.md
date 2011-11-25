# TRAC - Bot::BasicBot::Pluggable::Module::Brownian

Issue, to-do, and wish list, tracking file for the Brownian development project.

## ISSUES

## TO-DO

 - _(smpb, 24/11/2011)_ Deprecate this file and move all of this to a proper platform. Say, Github.

## WISH LIST

 - _(smpb, 24/11/2011)_ The bot's very own internal karma meter:
   - He dislikes people that 'botslap' him often
   - He likes people that 'botsnack' him (but not too often!)
   - He "feels" a kinship to those who have taught him more
   - Boilerplate replies (like greetings) should vary according to these metrics
   - _(nfn, 25/11/2011)_ The replies should be modulated by the user's recent interactions in the form of botslaps and botsnacks. In the extreme the bot should stop responding to the user after being heavilly abused

 - _(nfn, 25/11/2011)_ Implement a logging module.

 - _(nfn, 25/11/2011)_ Implement a 'backlog' module, allowing people to read the backlog for the last N [minutes|interactions] before they joined the channel. (See logging module)

 - _(nfn, 25/11/2011)_ Implement a 'substitute' module that catches phrases like 's/this/that/' and replies with 'user meant "latest user's phrase with substitution'


## SOLVED ISSUES

 - _(smpb, 24/11/2011)_ At every single restart of the bot, the RSS module parses all the feeds again and floods the channel with notifications. -- Solved by _(nfn, 25/11/1011)_
