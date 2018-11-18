#!/usr/bin/perl

#
#	$Id: filetest.pl,v 1.2 2006/12/04 02:04:36 bcaridad Exp $
#
#  Copyright (c) 2001-2002 Apple Computer, Inc. All rights reserved.
#

$argc = @ARGV;
if ( $argc > 2 ) {
	print "filetest.pl: Bad Parameters\n";
	exit (1);
}

$instances = $ARGV[0];
shift;
$loops = $ARGV[0];
@a = split(/t/, $loops);
if ( (@a + 0) == 2 ) {
	$seconds = $a[1] + 0;				# force it to scalar
	$loops = 1;
}
else {
	$seconds = 0;
}

$startTime = time;
$endTime = $startTime + $seconds;
$pidIndex = 0;
$err = 0;
$totalErrors = 0;
$Errors = 0;

if ( ! $ENV{StressPath} ) {
	$ENV{StressPath} = "./";
}

$prog = "filetest";
$logFile = "$ENV{StressLogPath}" . "$prog" . ".log";
$errorFile = "$ENV{StressLogPath}" . "$prog" . ".errors";
#$tmpPath = "/tmp/";


use POSIX ":sys_wait_h";

sub REAPER {									# wait for SIGCHILD and get it's exit status
	my $wpid;
	my $j;
	while (($wpid = waitpid(-1, &WNOHANG)) > 0) {
#		print "wpid: $wpid\n";
		for ($j = 1; $j <= $instances; $j++ ) {	
			if ( $wpid == $pids[$j] ) {
				$Errors[$j] = $?;			# exit status is the upper 8 bits of 16
				if ( $Errors[$j] ) {
					$totalErrors++;
				}					
				$pidIndex--;
				print "pid: $wpid finished, i= $index, errors = $errors\n";
			}
		}
	}
	return $wpid;
	print "start pid: $waitedpid finished, i= $index, errors = $Errors\n";
}

sub file_sig_handler {
	print "ABORT\n";
	kill HUP => -$$;
	exit 0;
}

open(LOG, ">>$logFile") || die "Cannot open $logFile";
print LOG "START $prog instances: $instances, loops: $loops, time: $seconds @ " . `date`;

$SIG{INT} = \&file_sig_handler;

# Find out what partitions are mounted
$data = `df -lk`;
@lines = split(/\n/, $data);
$numParts = 0;
foreach $line (@lines)
{
	if ($line =~ /^(\/dev\/disk)(.\S*)\s*(\d*.\s*\d*\S*)\s*(\d+\S*)\s*(.\S*)\s*(.+?)$/)
	{
#		print "1:$1 " . "2:$2 " . "3:$3 " . "4:$4 " . "5:$5 " . "6:$6\n";
		$err = system("mount -t hfs | grep $1$2 | grep -q read-only") / 256;
		if ( $err && ((length($2) > 2) && (length($2) < 5))) {
			push @mountedParts, [ $2, $3, $6 ];
			$numParts++;
		}
	}
}

# set up temp directories
for ( $part = 0; $part < $numParts; $part++ ) {
	if ( "$mountedParts[$part][2]" eq "/" ) {
		$dirname = "/tmp/tmp_test";
	} 
	else {
		$dirname = "$mountedParts[$part][2]/tmp_test";
	}
	$mountedParts[$part][2] = $dirname;		# change it to include the new dir name
	print LOG "$mountedParts[$part][2]\n";
#	$tofile[$part] = "$mountedParts[$part][2]/filetest$mountedParts[$part][0]";
#	print "XX  $tofile[$part]\n";
	if (! -d $dirname ) {
		if ( ($err = mkdir $dirname) ) {
			$partToTest[$part] = 1;
		} else {
			$partToTest[$part] = 0;
			print "Error $err creating $dirname\n";
		}
	}
	else {
		$partToTest[$part] = 1;
	}
}

$testfilename = "/tmp/dfiletest";

$passes = 0;

# if testing only with 1 partition then we run $instances of the copy, otherwise
# $instances refers to the number of partitions that get run concurrently
if ( ($instances == 1) || ($numParts > 1)) {
	$instances = $numParts;			# override instances if testing more than 1 partition
}
system("/bin/cp /mach_kernel \"$testfilename\"");
for ( $i=1; $i<=9; $i++ ) {
	system("/bin/cat /mach_kernel >> \"$testfilename\"");
}

$whileloop = 1;
while ( $whileloop == 1) {
	$pidIndex = 0;
	for ( $loop = 1; $loop <= $loops; $loop++ ) {
#		print "$prog loop $loop\n";
		for ( $i=1; $i<=$instances; $i++ ) {	# remove any previous log files
			if ( -e  "$logFile$i" ) {
				unlink ( "$logFile$i" );
			}
		}
		for ( $pidIndex=1; $pidIndex<=$instances; $pidIndex++ ) {			# start each one in the background
			if ( $numParts == 1 ) {
				$tofile[$pidIndex-1] = "$mountedParts[0][2]/filetest$pidIndex";
			} else {
				$tofile[$pidIndex-1] = "$mountedParts[$pidIndex-1][2]/filetest$pidIndex";
			}
			unless ($pids[$pidIndex] = fork) {
				exec ("/bin/cp \"$testfilename\" \"$tofile[$pidIndex-1]\" > \"$logFile$pidIndex\" 2>&1; /usr/bin/cmp \"$testfilename\" \"$tofile[$pidIndex-1]\" >> \"$logFile$pidIndex\" 2>&1");
			}
		}
		$pidIndex--;
		while ( $pidIndex > 0 ) {
			last if ( REAPER == -1 );
			sleep 5;							# don't waste too much cpu time
		}
	
		system("sync;sync;sync");
#		$i = 1;										# force an error for testing
#		system ("echo XXX >> $logFile$i");
		$dt = `date`;
		for ( $i=1; $i<=$instances; $i++ ) {
			if ( ($Errors[$i] & 127) != 0 ) {
				if (! open(ERRORFILE, ">>$errorFile")) {
					print LOG "Cannot open $errorFile";
				} else {
					$str = sprintf "### ERROR $prog QUIT at %s with error: 0x%x, exit status: %d, signal: %d, dumped core: %d\n", $dt, $Errors[$i],  $Errors[$i] >> 8,  $Errors[$i] & 127, $Errors[$i] & 128;
					print ERRORFILE "$str";
					close(ERRORFILE);
				}
			}
			else {
				if ( ! -z "$logFile$i" ) {			# it probably died
					open(ERRORFILE, ">>$errorFile") || die "Cannot open $errorFile";
					if ( ! open(LOGFILE, "$logFile$i")) {
						print ERRORFILE "Cannot open $logFile$i";
					} else {
						print ERRORFILE "Error $logFile$i file copy failed\n";
						print ERRORFILE " ### Error comparing $testfilename $logFile$i to $tofile[$i-1] at $dt\n ";
						while (<LOGFILE>) {
							print ERRORFILE $_;
						}
					}
					print ERRORFILE "-- END of log --\n\n";
					close(LOGFILE);
					close(ERRORFILE);
					$totalErrors++;
				}
				else {
					unlink("$logFile$i");
					unlink("$tofile[$i-1]");
				}
			}
		}
	}
	if ( $seconds  ) {
		$passes++;
		if ( time  >= ($endTime - 15)) {		# if we are within 15 seconds of ending, don't start again
			$whileloop = 0;
		}
	}
	else {
		$whileloop = 0;
	}
}

if ( $numParts == 1 ) {
		system("rm -rf \"$mountedParts[0][2]\"");
} else {
	for ( $i=0; $i<$instances; $i++ ) {
		system("rm -rf \"$mountedParts[$i][2]\"");
	}
}
unlink($testfilename);
$et = time - $startTime;
if ( $seconds ) {
	print LOG "filetest.pl - Elapsed Time: $et, Loops completed: $passes with $totalErrors Errors\n";
}
else {
	print LOG "filetest.pl - Elapsed Time: $et, Loops completed: $loops with $totalErrors Errors\n";
}
close(LOG);

exit ($totalErrors);

