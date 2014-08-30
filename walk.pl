#! /usr/bin/perl

use warnings;
use strict;
use Time::HiRes 'usleep';

my $keypress = 'KeyPress';
my $keyrelease = 'KeyRelease';
my $motionnotify = 'MotionNotify';
my $root = '    root ';
my $XLS = '    XLookupString gives ';
my $time0 = 0;
my $command;
my $key;
my $cmdln;
my $time;
my $mxpos;
my $mypos;
my $prevev = 'key';

die "usage:\n\tscript filename (xev output),\n\twindow id\n" if ($#ARGV < 1);
open(my $FSCRIPT, '<', $ARGV[0]);
my $wid = $ARGV[1];

# !!!!!!!!!!! CAUTION !!!!!!!!!!!!!!!!
# While in xev output newline doesn't have any
# special meaning, in this interpreter it means
# 'execute previously parsed command'
# keep this in mind!!!

print "WARNING:\nClean xev output before interpreting!\n";
foreach my $line (<$FSCRIPT>){
     if ($line =~ /^$keypress/){
	$command = 'keydown';

    }elsif ($line =~ /^$keyrelease/){
	$command = 'keyup';

    }elsif ($line =~ /^$motionnotify/){
	$command = 'mousemove';

    }elsif ($line =~ /^$root/){
	if ($line =~ /time ([0-9]+), \(([-0-9]+),([-0-9]+)\)/){
	    $time = $1;
	    $mxpos = $2;
	    $mypos = $3;
	    if (!$time0){
		$time0 = $time;
		$time = 0;
	    }else{
		my $tt = $time; 
		$time -= $time0;
		$time0 = $tt;
	    }
	}else{ die 'parsing error at root entry', $line; }
	
    }elsif ($line =~ /^$XLS/){
	if ($line =~ /"([a-zA-Z])"$/){
	    $key = $1;
	}else { die 'parsing error at XLS', $line; }

    }elsif ($line eq "\n"){
	# sweet, end of event description. now we can execute it
	$cmdln = 'xdotool ' . $command . ' --window ' . $wid . ' ';
	if ($command eq 'keydown'|| $command eq 'keyup'){
	     $cmdln .= $key;
	     if ($prevev eq 'mouse'){
		 # exec here
		 `xdotool click --window $wid 1`;
		 print "CLICK \n";
		 $prevev = 'key';
	     }
	}elsif ($command eq 'mousemove'){
	    $cmdln .= $mxpos . ' ' . $mypos;
	    $prevev = 'mouse';
	}else { die 'error at exec'; }
	usleep($time*1000);
	# exec here
	`$cmdln`;
	print $time . ' ' . $cmdln . "\n";
    }elsif ($line =~ /^#warning/){
	print $line;
    }else{ next; }
}
