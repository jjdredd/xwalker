#!/usr/bin/perl

use strict;
use warnings;

my $keyword;
my $command = "tcpdump -A host 91.123.197.149";

die "Usage: clicker.pl <keyword> <window ID>\n",
    "<keyword> must be one of the following:\n",
    "\t letter: search for a letter task\n",
    "\t loot: search for a loot task\n",
    "\t monster: search for a monster task\n",
    "\t player: search for a kill player task\n",
    "<window ID> is a game client window id\n" if($#ARGV < 1);

my $wid = $ARGV[1];
if($ARGV[0] eq "letter"){
    $keyword = "delivery_item";
}
elsif($ARGV[0] eq "loot"){
    $keyword = "give_item";
}
elsif($ARGV[0] eq "monster"){
    $keyword = "kill_monster";
}
elsif($ARGV[0] eq "player"){
    $keyword = "kill_player";
}
else{
    die "keyword not recognized\n";
}

open(FDP, "-|:unix", $command);
select FDP; $| = 1;
while(my $l = <FDP>){
    if(index($l, "REALM_TASK_") >= 0 ){
	sleep(5) if(index($l, $keyword) >= 0);
	`xdotool click --window $wid 1`;
    }
}
