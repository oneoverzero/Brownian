package Pisg::Parser::Format::bip;

use strict;
$^W = 1;

#bip
#
#17-02-2012 11:12:55 < nfn!~nfn@vs0205.flosoft-servers.net: mushroom mushroom
#17-02-2012 11:13:01 < * nfn!~nfn@vs0205.flosoft-servers.net sighs
#17-02-2012 11:13:21 < subetha!~subetha@vs0205.flosoft-servers.net: <joao.silva.neves> nfn: zip it up
#17-02-2012 11:13:52 < nfn!~nfn@vs0205.flosoft-servers.net: joao.silva.neves: you prefer to see it as unreadable text? OK, I can do that... :-)
#17-02-2012 11:14:11 > smpb: nfn: damn you, now I have that song in my head
#17-02-2012 11:14:20 < nfn!~nfn@vs0205.flosoft-servers.net: Great Success!

#moo
#
#2002-07-06 00:05:29 :vergil!~vergil@host PUBMSG #space :mike_lap: i'm not joking, actually.
#2002-07-04 15:56:19 :SpaceBot PUBMSG #space :huh?
#2002-07-06 00:07:30 :vergil!~vergil@host CTCP #space :ACTION salutes
#2002-07-18 10:37:18 :jeffcovey!~jeff@host KICK #space vergil :two days in a row!
#2002-07-06.log:2002-07-06 12:07:41 :phil_tty!mjpr@host TOPIC #space :<She-Ra> of course, god can go to rotters, for all she's managed not to do for me
#2002-07-04 17:34:01 :jeffcovey!~jeff@host MODE #space +o CowBot
#2002-07-04 12:02:42 :Leebert!~lsherida@host JOIN :#space
#2002-07-04 18:24:18 :mike_lap!~emag@host NICK :Cathy

sub new
{
    my ($type, %args) = @_;
    my $self = {
        cfg => $args{cfg},
        normalline => '^\d{2}-\d{2}-\d{4} (\d{2}):\d{2}:\d{2} [!-><]+ ([^! ]+)(?:![^ ]+)?: (.*)',
        proxyline  => '^\d{2}-\d{2}-\d{4} (\d{2}):\d{2}:\d{2} [!-><]+ [_\d\w><\[\]]+(?:![^ ]+)?: [<\[]([^! ]+)[>\]] (.*)',
        actionline => '(?:^\d{2}-\d{2}-\d{4} (\d{2}):\d{2}:\d{2} [!-><]+ \* ([^! ]+)(?:![^ ]+)? (.*))',
        thirdline  => '^\d{2}-\d{2}-\d{4} (\d{2}):(\d{2}):\d{2} [!-><]+ ([^! ]+)(?:![^ ]+)? (.*)',
    };

    bless($self, $type);
    return $self;
}

sub normalline
{
  my ($self, $line, $lines) = @_;
  my %hash;

  if ($line =~ /$self->{proxyline}/o)
  {
    $hash{hour}   = $1;
    $hash{nick}   = $2;
    $hash{saying} = utf8::decode($3);

    return if ($hash{nick} eq '...');
    return \%hash;
  }
  elsif ($line =~ /$self->{normalline}/o)
  {
    $hash{hour}   = $1;
    $hash{nick}   = $2;
    $hash{saying} = $3;

    return if ($hash{nick} eq '...');
    return \%hash;
  } else {
    return;
  }
}

sub actionline
{
  my ($self, $line, $lines) = @_;
  my %hash;

  if ($line =~ /$self->{actionline}/o)
  {
    $hash{hour}   = $1;
    $hash{nick}   = $2;
    $hash{saying} = $3;

    print "ACTION: '$hash{hour}' '$hash{nick}' '$hash{saying}'\n";

    return \%hash;
  } else {
    return;
  }
}

sub thirdline
{
  my ($self, $line, $lines) = @_;
  my %hash;

  if ($line =~ /$self->{thirdline}/o)
  {
    my $args = $6;

    $hash{hour} = $1;
    $hash{min}  = $2;
    $hash{nick} = $3;

    if ($line =~ /([^! ]+)(?:![^ ]+)? has been kicked by ([^! ]+)(?:![^ ]+)?/)
    {
      $hash{kicker} = $2;
      $hash{nick} = $1;

    }
    elsif ($line =~ /changed topic of [#\w\d\s]+ to: (.*)/)
    {
      $hash{newtopic} = $1;
    }
    elsif ($line =~ /mode/)
    {
      $hash{newmode} = $args;

    }
    elsif ($line =~ /([^! ]+)(?:![^ ]+)? has joined/)
    {
      $hash{newjoin} = $1;
    }

    return \%hash;

  # Nick changes do not have an associated channel.
  }
  elsif ($line =~ /$self->{thirdline}/o and $4 eq "NICK")
  {
    $hash{hour}    = $1;
    $hash{min}     = $2;
    $hash{nick}    = $3;
	  $hash{newnick} = $5;

    return \%hash;
  }
  else
  {
    return;
  }
}

1;
