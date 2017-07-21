#!/usr/bin/perl
use strict;

die "Usage: $0 <id_file> <seq_file> <out_file>\n"
  unless @ARGV == 3;

my $id_file  = shift;
my $seq_file = shift;
my $out_file = shift;

# read ids
my %ids_hash;
open ID, "<", $id_file
  or die "Failed to open file $id_file.\n";
while (<ID>) {
    next unless /(\S+)/;
    $ids_hash{$1} = 1;
}
close ID;

my @ids = keys %ids_hash;
my $n   = @ids;
print "read $n ids.\n";

# searching
open NT, "<", $seq_file
  or die "Failed to open file $seq_file.\n";
open OUT, ">", $out_file
  or die "Failed to open file $out_file.\n";

my ( $head, $seq );
local $/ = ">";
<NT>;
my $count = 0;
local $| = 1;
my $status = '';
my $hits   = 0;
while (<NT>) {
    $count++;

    s/\r?\n>//;
    ( $head, $seq ) = split "\n", $_, 2;
    $seq =~ s/\s+//g;

    next unless $head =~ /\s(\S+)\s\[/;

    if ( exists $ids_hash{$1} ) {
        print OUT ">$head\n$seq\n";
        delete $ids_hash{$1};
        $hits++;
    }

    $status = "${count}th sequence, hits: $hits";
    print "$status" . ( "\b" x ( length $status ) );
}
$/ = "\n";
close NT;
close OUT;
