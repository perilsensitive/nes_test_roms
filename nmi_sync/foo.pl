#! /usr/bin/perl

my $sum = 0;
my $odd = 0;
my $count = 0;

while (1) {
	$sum += 446710 - (5 * $odd);
	printf "%d: %d %d\n", $count, ($sum / 15) & 1, $odd;
	$odd ^= 1;
}

  
