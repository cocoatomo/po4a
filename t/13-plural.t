#! /usr/bin/perl
# MAN module tester.

#########################

use strict;
use warnings;

# Set the right environment variables to normalize the outputs
$ENV{'LC_ALL'}="C";
$ENV{'COLUMNS'}="80";

my @tests;

my @formats=qw(pod);

mkdir "t/tmp" unless -e "t/tmp";

my $diff_pod_flags= " -I 'This file was generated by po4a' ";

$tests[0]{'run'}  = "perl ../po4a-translate -f pod -k 0 -m t-13-plural/pod1 -p t-13-plural/pod1.po -l tmp/pod1.fr 2> tmp/err";
$tests[0]{'test'} = "diff -u t-13-plural/pod1.fr tmp/pod1.fr $diff_pod_flags 1>&2";
$tests[0]{'doc'}  = "Parse plural forms";

$tests[1]{'run'}  = "perl ../po4a-translate -f pod -k 0 -m t-13-plural/pod2 -p t-13-plural/pod1.po -l tmp/pod2.fr 2> tmp/err";
$tests[1]{'test'} = "diff -u t-13-plural/pod2.fr tmp/pod2.fr $diff_pod_flags 1>&2";
$tests[1]{'doc'}  = "Use singular form";

$tests[2]{'run'}  = "perl ../po4a-translate -f pod -k 0 -m t-13-plural/pod3 -p t-13-plural/pod1.po -l tmp/pod3.fr 2> tmp/err";
$tests[2]{'test'} = "diff -u t-13-plural/pod3.fr tmp/pod3.fr $diff_pod_flags 1>&2";
$tests[2]{'doc'}  = "Use plural form";

$tests[3]{'run'}  = "perl ../po4a-translate -f pod -k 0 -m t-13-plural/pod4 -p t-13-plural/pod1.po -l tmp/pod4.fr 2> tmp/err";
$tests[3]{'test'} = "diff -u t-13-plural/pod4.fr tmp/pod4.fr $diff_pod_flags 1>&2";
$tests[3]{'doc'}  = "Use single and plural form";

$tests[4]{'run'}  = "perl ../po4a-translate -f pod -k 0 -m t-13-plural/pod4 -p t-13-plural/pod1.po -l tmp/pod4.fr 2> tmp/err";
$tests[4]{'test'} = "diff -u t-13-plural/err1 tmp/err $diff_pod_flags 1>&2";
$tests[4]{'doc'}  = "Warn when using plural forms";

$tests[5]{'run'}  = "perl ../po4a-translate -f pod -k 0 -m t-13-plural/pod4 -p t-13-plural/pod2.po -l tmp/pod4.fr 2> tmp/err";
$tests[5]{'test'} = "diff -u t-13-plural/pod4.fr tmp/pod4.fr $diff_pod_flags 1>&2";
$tests[5]{'doc'}  = "Use single and plural form with multiple plural translations";

use Test::More tests =>12; # $formats * $tests * 2

foreach my $format (@formats) {
    for (my $i=0; $i<scalar @tests; $i++) {
        chdir "t" || die "Can't chdir to my test directory";

        my ($val,$name);

        my $cmd=$tests[$i]{'run'};
        $cmd =~ s/#format#/$format/g;
#	print STDERR "$cmd \n";
        $val=system($cmd);

        $name=$tests[$i]{'doc'}.' runs';
        $name =~ s/#format#/$format/g;
        ok($val == 0,$name);
        diag($cmd) unless ($val == 0);

        SKIP: {
            skip ("Command don't run, can't test the validity of its return",1)
              if $val;
            my $testcmd=$tests[$i]{'test'};
            $testcmd =~ s/#format#/$format/g;

            $val=system($testcmd);
            $name=$tests[$i]{'doc'}.' returns what is expected';
            $name =~ s/#format#/$format/g;
            ok($val == 0,$name);
            unless ($val == 0) {
                diag ("Failed (retval=$val) on:");
                diag ($testcmd);
                diag ("Was created with:");
                diag ("perl -I../lib $cmd");
            }
        }

#    system("rm -f tmp/* 2>&1");

        chdir ".." || die "Can't chdir back to my root";
    }
}

0;

