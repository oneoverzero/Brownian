package Bot::BasicBot::Pluggable::Module::Brownian;

use strict;
use Bot::BasicBot::Pluggable::Module; 
use base qw(Bot::BasicBot::Pluggable::Module);

# ways to say hello
my @hello = ('hello', 'hi', 'hey', 'bonjour', 'hola', 'salut', 'que tal',
             'whazup?', 'oh hai!');

# things to say when people thank me
my @welcomes = ('no problem', 'my pleasure', 'sure thing',
                'no worries', 'de nada', 'de rien', 'bitte', 'pas de quoi');

# ways to thank
my @thanks = ('thanks', 'much obliged', ':-)');

# ways to complain
my @complaints = ('What??', 'Ouch, stop that!', 'You hit like a girl!', 
                  'Is that all you got?!', 'SORRY MASTER!', 'YOU BITCH!',
		  'I\'M GONNA TELL!', 'I\'m gonna get you for that!',
		  'Ooh, you\'re a kinky one, aren\'t you?');

sub said { 
    my ($self, $mess, $pri) = @_;

    my $body = $mess->{body}; 
    my $who  = $mess->{who};

    my $nick      = $self->{nick} || "";
    my $addressed = $mess->{address};

    return unless ($pri == 2);

    # Gotta be gender-neutral here... we're sensitive to the bot's needs. :-)
    if ($body =~ /(good(\s+fuckin[\'g]?)?\s+(bo(t|y)|g([ui]|r+)rl))|(bot(\s|\-)?snack)/i) {
        my $reply = $thanks[int(rand(@thanks))];
	if (!$addressed) {
	    $reply .= ", $who";
	}
	return $reply;
    }

    if ($addressed && $body =~ /you (rock|rocks|rewl|rule|are so+ co+l)/i) {
        return $thanks[int(rand(@thanks))];
    }

    if ($addressed && $body =~ /thank(s| you)/i) {
        $reply = $welcomes[int(rand(@welcomes))];
    }     


    if ($body =~ /^\s*(h(ello|i( there)?|owdy|ey|ola)|salut|bonjour|niihau|que\s*tal)( $nick)?\s*$/i) {
        # 65% chance of replying to a random greeting when not addressed
        return if (!$addressed and rand() > 0.35);

        my($r) = $hello[int(rand(@hello))];
        return "$r, $who";
    }

    
    if ($body =~ /(bot(\s|\-)?(slap|spank))/i) {
        return $complaints[int(rand(@complaints))];
    }


}

sub help {
    return "Commands: 'botsnack', 'botspank', and a few more. Do explore. (nfn was here, btw, blame him if something goes wrong.)";
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

