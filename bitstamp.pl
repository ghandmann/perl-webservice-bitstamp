#!/usr/bin/env perl

use strict;
use warnings;
use 5.14.0;
use Data::Dumper;
use Mojo::UserAgent;
use Mojo::JSON qw /j/;

my $lastPrice = 0;

my $ua = Mojo::UserAgent->new();
$ua->inactivity_timeout(0);
$ua->on(error => sub {
	my ($tx, $error) = @_;
	say "*** ERROR: $error";
});

$ua->websocket("ws://ws.pusherapp.com/app/de504dc5763aeef9ff52?protocol=5" => sub {
	my ($ua, $tx) = @_;

	say 'WebSocket handshake failed!' and return unless $tx->is_websocket;

	$tx->on(error => sub {
		my ($tx, $error) = @_;
		say "*** ERROR: $error";
	});

	$tx->on(finish => sub {
		my ($tx, $code, $reason) = @_;
		$reason //= "Unknown reason!";
		say "WebSocket closed with status $code - $reason.";
	});
	$tx->on(message => \&on_message);
	$tx->on(trade => \&on_trade);
	
	$tx->send({
		json => {
			event => "pusher:subscribe",
			data => { channel => "live_trades" },
		}
	});
});

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

	my $trend;
	if($lastPrice < $price) {
		$trend = "UP";
	}
	elsif($lastPrice > $price) {
		$trend = "DOWN";
	}
	else {
		$trend = "SAME";
	}

	$lastPrice = $price;

	printf(' * Trade: %.3fBTC @ $%.2f - '."$trend\n", $amount, $price);
}

Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
