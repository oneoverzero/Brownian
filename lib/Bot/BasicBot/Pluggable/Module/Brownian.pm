package Bot::BasicBot::Pluggable::Module::Brownian;

use strict;
use Bot::BasicBot::Pluggable::Module;
use base qw(Bot::BasicBot::Pluggable::Module);

our $VERSION = 0.03;

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

    my @user_greetings  = $self->get('user_greetings');
    my @user_welcomes   = $self->get('user_welcomes');
    my @user_thanks     = $self->get('user_thanks');
    my @user_complaints = $self->get('user_complaints');

    if ( $addressed && $body =~ /^shutdown$/ && $self->authed($who) ) {
        warn __PACKAGE__ . ": Shutting down at the request of user $who\n";
        $self->tell( $mess->{channel},
            "At the request of $who, I am leaving. Goodbye." );

        # Horrible hack to deal with an ugly PoCo::RSSAggregator bug
        if ( grep( /rss/, $self->bot->modules ) ) {
            $self->bot->unload('rss');
        }
        $self->bot->shutdown("Shutting down");
    }

    # Gotta be gender-neutral here... we're sensitive to the bot's needs. :-)
    if ( $body =~
        /(good(\s+fuckin[\'g]?)?\s+(bo(t|y)|g([ui]|r+)rl))|(bot(\s|\-)?snack)/i
      )
    {
        my $reply = $user_thanks[ int( rand(@user_thanks) ) ];
        if ( !$addressed ) {
            $reply .= ", $who";
        }
        return $reply;
    }

    if ( $addressed && $body =~ /you (rock|rocks|rewl|rule|are so+ co+l)/i ) {
        return $user_thanks[ int( rand(@user_thanks) ) ];
    }

    if ( $addressed && $body =~ /thank(s| you)/i ) {
        return $user_welcomes[ int( rand(@user_welcomes) ) ];
    }

    if ( $body =~
/^\s*(h(ello|i( there)?|owdy|ey|ola)|salut|bonjour|niihau|que\s*tal)( $nick)?\s*$/i
      )
    {

        # 65% chance of replying to a random greeting when not addressed
        return if ( !$addressed and rand() > 0.35 );

        my ($r) = $user_greetings[ int( rand(@user_greetings) ) ];
        return "$r, $who";
    }

    if ( $body =~ /(bot(\s|\-)?(slap|spank))/i ) {
        return $user_complaints[ int( rand(@user_complaints) ) ];
    }

}

sub help {
    return "Commands: 'botsnack', 'botspank', and a few more. Do explore. (v $VERSION)";
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
