package Bot::BasicBot::Pluggable::Module::Brownian;

use strict;
use Bot::BasicBot::Pluggable::Module;
use base qw(Bot::BasicBot::Pluggable::Module);

our $VERSION = 0.05;

sub init {
    my $self = shift;

    warn __PACKAGE__ . ": Initializing module (v. $VERSION)\n";

    $self->config(
        {

            # ways to say hello
            user_greetings => [
                'hello', 'hi',    'hey',     'bonjour',
                'hola',  'salut', 'que tal', 'whazup?',
                'oh hai!'
            ],

            # things to say when people thank me
            user_welcomes => [
                'no problem',
                'my pleasure',
                'sure thing',
                'no worries',
                'de nada',
                'de rien',
                'bitte',
                'pas de quoi'
            ],

            # ways to thank
            user_thanks => [ 'thanks', 'much obliged', ':-)' ],

            # ways to complain
            user_complaints => [
                'What??',
                'Ouch, stop that!',
                'You hit like a girl!',
                'Is that all you got?!',
                'SORRY MASTER!',
                'YOU BITCH!',
                'I\'M GONNA TELL!',
                'I\'m gonna get you for that!',
                'Ooh, you\'re a kinky one, aren\'t you?'
            ],

            user_debug => 0,
        }
    );
}

sub said {
    my ( $self, $mess, $pri ) = @_;

    my $body = $mess->{body};
    my $who  = $mess->{who};

    my $nick = $self->{nick} || "";
    my $addressed = $mess->{address};

    return unless ( $pri == 2 );

    my $greetings  = $self->get('user_greetings');
    my $welcomes   = $self->get('user_welcomes');
    my $thanks     = $self->get('user_thanks');
    my $complaints = $self->get('user_complaints');

    # Admins can take me down
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

    # If either NickServ or an admin ask me to identify myself and
    # I have a password, do it
    if (
        $addressed
        && (
            (
                ( $who eq 'NickServ' )
                && ( $body =~
/^This nickname is registered. Please choose a different nickname, or identify via/
                )
            )
            || ( $self->authed($who)
                && ( $body eq 'authenticate' ) )
        )
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

    # Gotta be gender-neutral here... we're sensitive to the bot's needs. :-)
    if ( $body =~
        /(good(\s+fuckin[\'g]?)?\s+(bo(t|y)|g([ui]|r+)rl))|(bot(\s|\-)?snack)/i
      )
    {
        my $reply = $thanks->[ int( rand( scalar(@$thanks) ) ) ];
        if ( !$addressed ) {
            $reply .= ", $who";
        }
        return $reply;
    }

    if ( $addressed && $body =~ /you (rock|rocks|rewl|rule|are so+ co+l)/i ) {
        return $thanks->[ int( rand( scalar(@$thanks) ) ) ];
    }

    if ( $addressed && $body =~ /thank(s| you)/i ) {
        return $welcomes->[ int( rand( scalar(@$welcomes) ) ) ];
    }

    if ( $body =~
/^\s*(h(ello|i( there)?|owdy|ey|ola)|salut|bonjour|niihau|que\s*tal)( $nick)?\s*$/i
      )
    {

        # 65% chance of replying to a random greeting when not addressed
        return if ( !$addressed and rand() > 0.35 );

        my ($r) = $greetings->[ int( rand( scalar(@$greetings) ) ) ];
        return "$r, $who";
    }

    if ( $body =~ /(bot(\s|\-)?(slap|spank))/i ) {
        return $complaints->[ int( rand( scalar(@$complaints) ) ) ];
    }

}

sub help {
    return
"Commands: 'botsnack', 'botspank', 'shutdown', 'authenticate' and a few more. Do explore! (v $VERSION).";
}

1;

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

