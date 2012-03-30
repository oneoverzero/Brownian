package Bot::BasicBot::Pluggable::Module::Brownian::Status;

use strict;
use Bot::BasicBot::Pluggable::Module;
use base qw(Bot::BasicBot::Pluggable::Module);

sub init {
    my $self = shift;
    $self->{uptime} = time();
    $self->config( { user_relay_bot => 'SubEtha' } );
}

sub said {
    my ( $self, $mess, $pri ) = @_;
    $mess = $self->deal_with_relay_bot($mess);

    my $body    = $mess->{body};
    my $who     = $mess->{who};
    my $address = $mess->{address};

    return unless ( $pri == 2 );
    return unless $body =~ /^\s*status/i && $address;

    my $started = $self->{uptime};
    my $uptime  = time() - $started;

    my $day  = 24 * 60 * 60;
    my $hour = 60 * 60;
    my $min  = 60;

    my $days = int( $uptime / $day );
    $uptime %= $day;
    my $hours = int( $uptime / $hour );
    $uptime %= $hour;
    my $mins = int( $uptime / $min );
    $uptime %= $min;

    my $store = $self->bot->store;
    return "Errk, couldn't get to factoids" unless defined $store;

    my @keys = $store->keys('Infobot');
    $self->reply( $mess, "I don't think you've loaded the Infobot module" )
      unless @keys;

    my $factoids = 0;
    my $mods     = 0;
    foreach my $key (@keys) {
        next unless $key =~ /^infobot_/;
        foreach my $atom ( @{ $store->get( 'Infobot', $key )->{factoids} } ) {
            $factoids++;

            #$mods++     if $atom->{create_time} >= $self->{uptime};
        }
    }

    my $return = "";

    #    if (@keys) {
    #        $return .= "Since ".localtime($started)." there ha".
    #        $return .= "".(($mods!=1)?"ve":"s");
    #            $return .= " been $mods modification";
    #        $return .= "s" if $mods != 1;
    #        $return .= ". ";
    #    }
    $return .=
"I have been awake $days days, $hours hours, $mins minutes, $uptime seconds this session";
    if (@keys) {
        $return .= ", and currently reference $factoids factoid";
        $return .= "s" if $factoids != 1;
        $return .= ". ";
    }
    return $return;
}

sub help {
    return "Commands: 'status'";
}

sub deal_with_relay_bot {
    my ( $self, $mess ) = @_;

    my $relay_bot = $self->get('user_relay_bot');

    if ( lc( $mess->{who} ) ne lc($relay_bot) ) {
        return $mess;
    }

    my $new_mess = {};
    my ( $trash, $new_body ) = $mess->{body} =~ /(<.+?> )?(.+)/;
    my ($new_who) = $mess->{body} =~ /<(.+?)> /;
    my $my_nick = $self->bot->nick;
    if ( $new_body =~ /^$my_nick:\s+(.*)$/ ) {

        #warn __PACKAGE__ . ": I am being addressed from beyond the mirror!";
        $new_mess->{address} = $my_nick;
        $new_body = $1;
    }

    #warn __PACKAGE__ . ": \$new_body: \"$new_body\"; \$new_who: \"$new_who\"";
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

Bot::BasicBot::Pluggable::Module::Spell - get the status of the bot

=head1 IRC USAGE

    status

=head1 AUTHOR

Simon Wistow, <simon@thegestalt.org>

=head1 COPYRIGHT

Copyright 2005, Simon Wistow

Distributed under the same terms as Perl itself.

=head1 SEE ALSO

=cut 

