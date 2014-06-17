package WebService::Bitstamp;

use Mojo::Base "Mojo::EventEmitter";
use Mojo::UserAgent;

our $VERSION = '0.01';

has 'ua' => sub { Mojo::UserAgent->new(); };

sub connect {
	my $self = shift;
	$self->ua->inactivity_timeout(0);

	$self->ua->on(error => sub {
		my ($tx, $error) = @_;
		die " * FATAL: $error";
	});

	$self->ua->websocket("ws://ws.pusherapp.com/app/de504dc5763aeef9ff52?protocol=5" => sub {
		my ($ua, $tx) = @_;

		say 'WebSocket handshake failed!' and return unless $tx->is_websocket;

		$tx->on(error => sub {
			my ($tx, $error) = @_;
			say "*** ERROR: $error";
		});

		$tx->on(finish => sub {
			my ($tx, $code, $reason) = @_;
			$reason //= "Unknown reason!";
			say "WebSocket closed with status $code and reason: $reason.";
		});

		$tx->on(message => $self->on_message);
		$tx->on(trade => $self->on_trade);
		
		$tx->send({
				json => {
				event => "pusher:subscribe",
				data => { channel => "live_trades" },
			}
		});
	});
}

sub on_message {
	my ($tx, $msg) = @_;
	my $data = j($msg);
	given ($data->{event}) {
		when ("pusher:connection_established") { say " * Connected to API" }
		when ("pusher_internal:subscription_succeeded") { say " * Subscribed to channel " . $data->{channel} }
		when ("trade") { $tx->emit("trade", $data); }
		default { say " * UNHANDLED MSG: " . Dumper $data }
	}
}

sub on_trade {
	my ($tx, $msg) = @_;
	my $trade = j($msg->{data});

	my ($price, $amount) = ($trade->{price}, $trade->{amount});

	my $trend = "Unknown";

	printf(' * Trade: %.3fBTC @ $%.2f - '."$trend\n", $amount, $price);
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

WebService::Bitstamp - Perl extension for blah blah blah

=head1 SYNOPSIS

  use WebService::Bitstamp;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for WebService::Bitstamp, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

ghandi, E<lt>ghandi@E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by ghandi

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
