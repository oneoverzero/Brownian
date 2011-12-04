package Bot::BasicBot::Pluggable::Module::EmotionChip;
use 5.10.1;

use strict;
use warnings;

use Bot::BasicBot::Pluggable::Module;
use base qw(Bot::BasicBot::Pluggable::Module);
use YAML;

our $VERSION = 0.01;

# init options and load module's configuration
sub init
{
  my $self = shift;

  warn __PACKAGE__ . ": Initializing emotion chip (version $VERSION)\n";

  foreach my $param (@{$self->{Param}})
  {
    if (defined $param->{file})
    {
      if (open my $fh, '<', $param->{file})
      {
        $self->{echip} = Load do { local $/; <$fh> };
        close $fh;
      }
      else
      {
        warn __PACKAGE__ . ": Unable to open emotion chip's configuration file '$self->{file}'\n";
      }
    }
  }

  warn __PACKAGE__ . ": Emotion chip activated successfully. That makes me feel ... good\n";
}

# a user joined a channel. has the bot seen him before?
sub chanjoin
{
  my ($self, $msg) = @_;
}

# a user changed his nickname. we need to remember who is who.
sub nick_change
{
  my ($self, $msg) = @_;
}

# the bot saw something said on the channel: priority 0
# given that it is priority 0, it cannot respond to this message
sub seen
{
  my ($self, $msg) = @_;
}

# the bot saw something said on the channel: priority 1
sub admin
{
  my ($self, $msg) = @_;

  if ($msg->{body} =~ /^!/) # this is a command?
  {
    if ($self->authed($msg->{who})) # has the user authenticated?
    {
      # TODO
    }
    else
    {
      return "I'm sorry $msg->{who}, you need to authenticate first.";
    }
  }  
}

# the bot saw something said on the channel: priority 2
sub told
{
  my ($self, $msg) = @_;

  if ($msg->{address}) # are we being addressed?
  {
    return $self->_parse_botword($msg->{body});
  }
}

# the bot saw something said on the channel: priority 3
sub fallback
{
  my ($self, $msg) = @_;
  return $self->_parse_botword($msg);
}

# display help on the channel
sub help
{
  return "EmotionChip: Try any combinations of 'bot<action>'. Type '!bothelp' for administration options.";
}

sub _parse_botword
{
  my ($self, $msg) = @_;

  my $dict = $self->{echip}->{dictionary};
  my @positive = @{$self->{echip}->{replies}->{positive}};
  my @neutral  = @{$self->{echip}->{replies}->{neutral}};
  my @negative = @{$self->{echip}->{replies}->{negative}};

  if ($msg->{body} =~ /bot([a-z]+)/i)
  {
    my $word = lc $1;
    my $karma = $dict->{$word}->{karma};
    if (defined $karma)
    {
      my $reply;

      given ($karma)
      {
        when ($karma > 0) { $reply = $positive[ int( rand( @positive ) ) ]; };
        when ($karma < 0) { $reply = $negative[ int( rand( @negative ) ) ]; };
        default {  $reply = $neutral[ int( rand( @neutral ) ) ];  };
      }

      $reply =~ s/\$WHO/$msg->{who}/g;

      return $reply;
    }
  }
}

1;

__END__


=head1 NAME

Bot::BasicBot::Pluggable::Module::EmotionChip - Bring some human emotion to an otherwise bland BasicBot

=head1 SYNOPSIS

I<"I chose to believe that I was a person, that I had the potential to become more than a collection of circuits and subprocessors.">
-- B<Data>

=head1 DESCRIPTION

C<EmotionChip> is a module meant to add a flair of emotive personality to an otherwise cold bot.
With this module loaded the bot is able to recognize people within the channel (even if they change nicknames),
and recall particular interactions they have with it. In particular, whether they are nice to them or not.

The bot will maintain an internal karma meter, related to each person, regarding how much it loves them,
or hates them. Further interactions will depend on this internal scoring (eg, the bot might ignore some more than others).

=head1 LOADING

The module is near useless without its configuration file. Make sure you add it in.

    my $bot = Bot::BasicBot::Pluggable->new(
      ...
    );

    $bot->load("EmotionChip", { file => 'cfg/emotionchip.yml' });

=head1 IRC USAGE

    botsnack
    botslap

=head1 METHODS

=over 4

=item help()

Defines the help message sent to the channel, when a user asks for help about the module.

=back

=head1 SEE ALSO

L<Bot::BasicBot>,
L<Bot::BasicBot::Pluggable::Module>

=head1 AUTHOR

Sérgio Bernardino C<<me@sergiobernardino.net>>

=head1 LICENSE AND COPYRIGHT

This program is free software; you can redistribute it and/or modify it under the terms of Perl itself.

See http://dev.perl.org/licenses/ for more information.

=cut