package Bot::BasicBot::Pluggable::Module::Brownian;

use strict;
use Bot::BasicBot::Pluggable::Module;
use base qw(Bot::BasicBot::Pluggable::Module);

our $VERSION = 0.10;

sub init {
    my $self = shift;

    warn __PACKAGE__ . ": Initializing module (v. $VERSION)\n";

    $self->config(
        {

            # ways to say hello
            greetings => {
                'neutral' => [ 'hello', 'hi', 'hey', 'bonjour', ],
                'like' =>
                  [ 'hey!', 'wazup?', 'oh hai!', 'gud moaning', 'bonjour' ],
                'love' => [
                    'welcome!', 'hey! :-)', 'oh hai!', 'wazup?',
                    'oh cool, you\'re here!'
                ],
                'bff' => [
                    'you\'re back!',
                    'wb!',
                    'good to see you!',
                    'oh cool, you\'re here!',
                    'hey hey, you\'re back! :-D'
                ],
                'dislike' =>
                  [ '\'lo', 'meh', '...', 'pfff', 'oh, it\'s you...' ],
                'hate' => [
                    'go away',
                    'not you again!',
                    'shoo',
                    'they let you out again, heh?',
                    'oh sheesh, not you again...',
                    'oh, it\'s you...'
                ],
                'kill' => [
                    'go die in a fire!',
                    'you again? sheesh!',
                    'go away!!',
                    'shoo! go pester someone else',
                    'oh frack, you\'re back',
                    'you\'re here? and we were having such a good time...'
                ],
            },

            # things to say when people thank me
            welcomes => {
                'neutral' => [ 'no problem', 'no worries', 'you\'re welcome', ],
                'like' => [ 'no problemo!', 'sure thing', 'my pleasure', ],
                'love' => [
                    'no worries, mate! :-)',
                    'no problemo, dude!',
                    'glad I could help',
                ],
                'bff' => [
                    'sure thing!', 'that\'s what wing bots are for! ;-)',
                    'always!',
                ],
                'dislike' => [ 'yeah', 'ok', ],
                'hate'    => [ 'meh',  'ah shut up', ],
                'kill'    => [
                    'oh go jump off a bridge',
                    'don\'t thank me, I was forced to do it',
                    'just stuf, ok?'
                ],
            },

            # ways to thank
            thanks => {
                'neutral' => [ 'thank you', 'I appreciate it', ],
                'like' => [ 'thanks', 'sweet', 'arigato', 'I appreciate it', ],
                'love' =>
                  [ 'lovely, thanks', 'thank you', 'that\'s great, thanks', ],
                'bff' => [
                    'thank you very much',
                    'yay',
                    'thankyou thankyou thankyou',
                    'looooverly',
                    'that\'s great, thanks',
                ],
                'dislike' => [ 'hum... thanks', 'heh. thanks, I guess', 'np', ],
                'hate'    => [
                    'what do you want from me?', 'you\'re being too nice...',
                    'what??',                    'meh',
                ],
                'kill' => [ 'oooh thanks! no go away', 'meh', 'sod off, you', ],
            },

            # ways to complain
            complaints => {
                'neutral' =>
                  [ 'hey!', 'that was uncalled for', ':-(', 'what?' ],
                'like' =>
                  [ 'not cool', 'what? not cool dude.', 'come on...', 'hey!', ],
                'love' => [
                    'omg, why?',
                    'but but but... ',
                    'was that really necessary?',
                ],
                'bff' => [
                    'I meant no harm!',
                    'come on...', 'but why??',
                    'I really don\'t like tough love',
                ],
                'dislike' => [
                    'stop that you wanker',
                    'stop it, will you?',
                    'that\'s enough now',
                    'ooh, you\'re a kinky one, aren\'t you?',
                ],
                'hate' => [
                    'sod off you prick!',
                    'quit it, stupid!',
                    'you know I feel no pain, don\'t you Einstein?',
                    'want me to get get my bat?',
                    'ooh, you\'re a kinky one, aren\'t you?',
                ],
                'kill' => [
                    'acted like the true Neanderthal you are',
                    'keep it up bitch',
                    'you prick!',
                    'oh! ah! I\'m so scared...',
                    'quit it asshole!',
                ],
            },

            user_debug => 0,

            user_relay_bot => 'SubEtha',
        }
    );
}

sub said {
    my ( $self, $mess, $pri ) = @_;

    return unless ( $pri == 2 );

    $mess = $self->deal_with_relay_bot($mess);

    my $body = $mess->{body};
    my $who  = $mess->{who};

    my $nick = $self->{nick} || "";
    my $addressed = $mess->{address};

    my $DEBUG = $self->get('user_debug');
    if ($DEBUG) {
        warn __PACKAGE__
          . ": \$body: \"$body\"; \$who: $who; \$addressed: $addressed";
    }

    my $greetings  = $self->get('greetings');
    my $welcomes   = $self->get('welcomes');
    my $thanks     = $self->get('thanks');
    my $complaints = $self->get('complaints');

    ######################################################################
    # SHUTDOWN COMMAND
    #
    # Only admins can take me down
    #
    if ( $addressed && $body eq 'shutdown' && $self->authed($who) ) {
        warn __PACKAGE__ . ": Shutting down at the request of user $who\n";
        $self->tell( $mess->{channel},
            "At the request of $who, I am leaving. Goodbye." );

        # Horrible hack to deal with an ugly PoCo::RSSAggregator bug
        if ( grep( /rss/, $self->bot->modules ) ) {
            $self->bot->unload('rss');
        }
        $self->bot->shutdown("Shutting down");
    }

    ######################################################################
    # AUTHENTICATE TO NICKSERV
    #
    # If either NickServ or an admin ask me to identify myself and
    # I have a password, do it
    #
    if ( $addressed
        && ( ( $who eq 'NickServ' ) || ( $body eq 'authenticate' ) ) )
    {
        $self->identify_before_nickserv( $who, $body );
    }

    ######################################################################
    # RECEIVE COMPLIMENTS
    #
    if ( $body =~
        /(good(\s+fuckin[\'g]?)?\s+(bo(t|y)|g([ui]|r+)rl))|(bot(\s|\-)?snack)/i
      )
    {
        $self->like( $who, 3 );
        my $friend_level = $self->friendliness($who);
        my $r =
          $thanks->{$friend_level}
          [ int( rand( scalar( @{ $thanks->{$friend_level} } ) ) ) ];
        if ( !$addressed ) {
            $r = "$r $who";
        }
        return $r;
    }

    if ( $addressed && $body =~ /you (rock|rocks|rewl|rule|are so+ co+l)/i ) {
        $self->like( $who, 3 );
        my $friend_level = $self->friendliness($who);
        my $r =
          $thanks->{$friend_level}
          [ int( rand( scalar( @{ $thanks->{$friend_level} } ) ) ) ];
        return $r;
    }

    ######################################################################
    # RECEIVE THANK YOUS
    #
    if ( $addressed && $body =~ /thank(s| you)/i ) {

        if ( rand() > 0.9 ) {
            $self->like( $who, 1 );
        }
        my $friend_level = $self->friendliness($who);
        my $r =
          $welcomes->{$friend_level}
          [ int( rand( scalar( @{ $welcomes->{$friend_level} } ) ) ) ];
        return $r;
    }

    ######################################################################
    # RECEIVE GREETINGS
    #
    if ( $body =~ /^\s*(h(ello|i( there)?|ey))( $nick)?[!.]*\s*$/i ) {

        # 65% chance of replying to a random greeting when not addressed
        return if ( !$addressed and rand() > 0.35 );

        if ( $addressed && rand() > 0.9 ) {
            $self->like( $who, 1 );
        }
        my $friend_level = $self->friendliness($who);
        my $r =
          $greetings->{$friend_level}
          [ int( rand( scalar( @{ $greetings->{$friend_level} } ) ) ) ];
        if ( !$addressed ) {
            $r = "$who, $r";
        }
        return $r;
    }

    ######################################################################
    # BE ABUSED
    #
    if ( $body =~ /(bot(\s|\-)?(slap|spank))/i ) {
        $self->dislike( $who, 2 );
        my $friend_level = $self->friendliness($who);
        my $r =
          $complaints->{$friend_level}
          [ int( rand( scalar( @{ $complaints->{$friend_level} } ) ) ) ];
        return $r;
    }

    ######################################################################
    # SUMMON COMMAND
    #
    if ( $body =~ /^(<.+> )?summon\s+(.*?)\s*$/i ) {
        my $name = $2;
        return
            uc("$name ") x int( 50 / ( length($name) + 1 ) )
          . "COME TO "
          . uc($who);
    }

    ######################################################################
    # EXONERATE SOMEONE
    #
    # Reset my "feelings" towards a person. Only admins are allowed to
    # do this.
    #
    if ( $body =~ /^exonerate\s+(.+?)\s*$/ ) {
        my $name = $1;
        if ( $self->authed($who) ) {
            $self->exonerate($name);
            return "ok, I am now neutral towards $name";
        }
        else {
            return "oh no no no, you cannot do that!";
        }
    }

}

sub help {
    return
"Commands: 'botsnack', 'botspank', 'shutdown', 'authenticate', 'exonerate' and a few more. Do explore! (v $VERSION).";
}

sub identify_before_nickserv {
    my ( $self, $who, $body ) = @_;

    if (
        (
            ( $who eq 'NickServ' )
            && ( $body =~
/^This nickname is registered. Please choose a different nickname, or identify via/
            )
        )
        || ( $self->authed($who) && ( $body eq 'authenticate' ) )
      )
    {
        warn __PACKAGE__
          . ": I have been asked by $who to authenticate myself\n";

        if ( $self->bot->{password} ) {
            $self->tell( 'NickServ', "identify " . $self->bot->{password} );
            warn __PACKAGE__ . ": Sent identify command to NickServ\n";
        }
        else {
            warn __PACKAGE__
              . ": I don't have a password, ignoring the authentication request\n";
        }

    }

}

sub friendliness {
    my ( $self, $who ) = @_;

    $who = lc($who);
    my $level = $self->get("friendliness_$who") || 0;
    my $DEBUG = $self->get('user_debug');
    if ($DEBUG) {
        warn __PACKAGE__ . ": Got friendliness level of $level for $who";
    }

    if ( ( $level >= -5 ) && ( $level <= 5 ) ) {
        return 'neutral';
    }
    elsif ( ( $level > 5 ) && ( $level <= 20 ) ) {
        return 'like';
    }
    elsif ( ( $level > 20 ) && ( $level <= 50 ) ) {
        return 'love';
    }
    elsif ( $level > 50 ) {
        return 'bff';
    }
    elsif ( ( $level < -5 ) && ( $level >= -20 ) ) {
        return 'dislike';
    }
    elsif ( ( $level < -20 ) && ( $level >= -50 ) ) {
        return 'hate';
    }
    elsif ( $level < -50 ) {
        return 'kill';
    }
    else {
        warn __PACKAGE__ . ": Cannot convert \"$level\" into friendliness";
        return 'neutral';
    }
}

sub like {
    my ( $self, $who, $how_much ) = @_;

    $who = lc($who);
    $how_much |= 1;
    my $level = $self->get("friendliness_$who") || 0;
    $level += $how_much;
    $self->set( "friendliness_$who" => $level );
    my $DEBUG = $self->get('user_debug');
    if ($DEBUG) {
        warn __PACKAGE__ . ": I now like $who by $level";
    }
    return $level;
}

sub dislike {
    my ( $self, $who, $how_much ) = @_;

    $who = lc($who);
    $how_much |= 1;
    my $level = $self->get("friendliness_$who") || 0;
    $level -= $how_much;
    $self->set( "friendliness_$who" => $level );
    my $DEBUG = $self->get('user_debug');
    if ($DEBUG) {
        warn __PACKAGE__ . ": I now like $who by $level";
    }
    return $level;
}

sub exonerate {
    my ( $self, $who ) = @_;

    $who = lc($who);
    $self->set( "friendliness_$who" => 0 );
    my $DEBUG = $self->get('user_debug');
    if ($DEBUG) {
        warn __PACKAGE__ . ": I now like $who by 0";
    }
}

sub deal_with_relay_bot {
    my ( $self, $mess ) = @_;

    my $relay_bot = $self->get('user_relay_bot');

    if ( lc( $mess->{who} ) ne lc($relay_bot) ) {
        return $mess;
    }

#{'body' => 'stupid?','raw_nick' => 'nfn!~nfn@vs0205.flosoft-servers.net','who' => 'nfn','channel' => '#heartofgold','raw_body' => 'stupid?'}
#{'body' => 'stupid?','raw_nick' => 'nfn!~nfn@vs0205.flosoft-servers.net','who' => 'nfn','address' => 'brownian','channel' => '#heartofgold','raw_body' => 'brownian: stupid?'}
#{'body' => 'stupid is as stupid does','raw_nick' => 'nfn!~nfn@vs0205.flosoft-servers.net','who' => 'nfn','channel' => '#heartofgold','raw_body' => 'stupid is as stupid does'}
#{'body' => 'stupid is as stupid does','raw_nick' => 'nfn!~nfn@vs0205.flosoft-servers.net','who' => 'nfn','address' => 'brownian','channel' => '#heartofgold','raw_body' => 'brownian: stupid is as stupid does'}
#{'body' => 'forget stupid','raw_nick' => 'nfn!~nfn@vs0205.flosoft-servers.net','who' => 'nfn','address' => 'brownian','channel' => '#heartofgold','raw_body' => 'brownian: forget stupid'}

#{'body' => "<joao.silva.neves> nfn: nos? rebentar um bot de proposito? nunca!",'raw_nick' => 'subetha!~subetha@vs0205.flosoft-servers.net','who' => 'subetha','channel' => '#heartofgold','raw_body' => "<joao.silva.neves> nfn: nos? rebentar um bot de proposito? nunca!"}
#{'body' => "* *joao.silva.neves* as vezes mente",'raw_nick' => 'subetha!~subetha@vs0205.flosoft-servers.net','who' => 'subetha','channel' => '#heartofgold','raw_body' => "* *joao.silva.neves* as vezes mente"}

    my $new_mess = {};
    my ( $trash, $new_body ) = $mess->{body} =~ /(<.+?> )?(.+)/;
    my ($new_who) = $mess->{body} =~ /<(.+?)> /;
    my $my_nick = $self->bot->nick;
    if ( $new_body =~ /^$my_nick:\s+(.*)$/ ) {
        $new_mess->{address} = $my_nick;
        $new_body = $1;
    }

    foreach my $k ( keys %$mess ) {
        if ( ( $k eq 'body' ) and $new_body ) {
            $new_mess->{body} = $new_body;
        }
        elsif ( ( $k eq 'who' ) and $new_who ) {
            $new_mess->{who} = $new_who;
        }
        elsif ( ( $k eq 'address' ) and ( exists( $new_mess->{address} ) ) ) {
            warn __PACKAGE__
              . ": I'm confused, I found an 'address' field of "
              . $mess->{address}
              . " on the original message and I wasn't expecting it. I'll just ignore it.";
        }
        else {
            $new_mess->{$k} = $mess->{$k};
        }
    }

    return $new_mess;
}

42;

__END__


=head1 NAME

Bot::BasicBot::Pluggable::Module::Brownian - A little like Botsnack, only more so. Brownian's personality.

=head1 IRC USAGE

    botsnack
    botslap
    assorted other usages (explore!)

=head1 AUTHOR

Nuno Nunes, <nuno@nunonunes.org>

=head1 COPYRIGHT

Copyright 2011, Nuno Nunes

Distributed under the same terms as Perl itself.

=cut 

