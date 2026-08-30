#!/usr/bin/env perl

use strict;
use warnings;

use POSIX qw(strftime);

# Secure Log Analyzer
# Perl script to analyze Linux secure/auth.log files
# By Nicholas Grogg
# Revision: 20260829

# Function to run program
sub runProgram {
    print "Secure Log Analyzer - ", strftime('%Y%m%d', localtime), "\n";
    print "----------------------------------------------------\n";

    ## Variables
    ### Log file variables
    #### Path to the authentication log used by Debian-based distributions.
    my $auth_log        = '/var/log/auth.log';

    #### Path to the authentication log used by Red Hat/Fedora-based distributions.
    my $secure_log      = '/var/log/secure';

    #### Stores the path of the log file that will actually be analyzed.
    my $log_file;

    ### Auth variables
    #### Total number of failed authentication attempts found in the log.
    my $failed_auth     = 0;

    #### Number of failed authentication attempts associated with SSH.
    my $ssh_failures    = 0;

    #### Total number of successful SSH authentications found in the log.
    my $successful_auth = 0;

    ### Hash arrays for failed IPs/users
    my %failed_ips;
    my %failed_users;

    ## Prefer /var/log/secure if both files exist.
    if (-f $secure_log) {
        $log_file = $secure_log;
    }
    elsif (-f $auth_log) {
        $log_file = $auth_log;
    }
    ## Neither supported authentication log was found.
    else {
        ### Stop execution and display an error message.
        die "Error: Could not find $secure_log or $auth_log\n";
    }

    ## Open the selected log file for reading.
    ## The '<' mode opens the file as read-only.
    ## $fh is the filehandle used to read the contents of the log.
    open(my $fh, '<', $log_file)
        or die "Error: Could not open $log_file: $!\n";

    ## While loop to iterate through log file
    while (my $line = <$fh>) {

        ### Failed authentication
        if ($line =~ /Failed password for (?:invalid user )?(\S+) from (\S+)/) {

            #### $1 contains the username captured by the first (\S+).
            my $user = $1;

            #### $2 contains the IP address captured by the second (\S+).
            my $ip   = $2;

            #### Increment the total failed authentication count.
            $failed_auth++;

            #### Increment the failure count for this IP address.
            $failed_ips{$ip}++;

            #### Increment the failure count for this username.
            $failed_users{$user}++;

            #### Increment the SSH-specific failure count.
            $ssh_failures++;

            #### Skip the remaining checks for this log line and move to the next line
            next;
        }


        ### Invalid user attempts
        if ($line =~ /Invalid user (\S+) from (\S+)/) {

            #### $1 contains the attempted username.
            my $user = $1;

            #### $2 contains the source IP address.
            my $ip   = $2;

            #### Increment the total failed authentication count.
            $failed_auth++;

            #### Increment the failure count for this IP address.
            $failed_ips{$ip}++;

            #### Increment the failure count for this username.
            $failed_users{$user}++;

            #### Increment the SSH-specific failure count.
            $ssh_failures++;

            #### This line has already been identified as an SSH failure,
            #### Skip the remaining checks and continue with the next line.
            next;
        }


        ### Successful SSH authentication
        if ($line =~ /Accepted (?:password|publickey|keyboard-interactive\/pam) for (\S+) from (\S+)/) {

            #### Increment the successful SSH authentication count.
            $successful_auth++;

            #### This line has been handled, so continue with the next line of the log
            next;
        }


        ### Generic authentication failure
        if ($line =~ /authentication failure/i) {

            # Increment the total failed authentication count.
            $failed_auth++;
        }
    }

    # Close the authentication log after all lines have been processed.
    close($fh);


    ## Output
    ### Add a blank line before the report.
    print "\n";

    print "Authentication Log Report\n";
    print "----------------------------------------------------\n";
    print "Log file: $log_file\n";
    print "\n";
    print "Authentication Summary\n";
    print "----------------------------------------------------\n";

    ### Display the total number of failed authentication attempts.
    printf "Failed authentication attempts: %d\n", $failed_auth;
    printf "Successful SSH authentications: %d\n", $successful_auth;
    printf "SSH-related failures:           %d\n", $ssh_failures;
    print "\n";

    ### Display the failed IP address section heading.
    print "Top Offending IP Addresses\n";
    print "----------------------------------------------------\n";

    ### Check whether the failed IP hash contains any entries.
    if (%failed_ips) {

        #### Iterate through the IP addresses after sorting them.
        #### If two IP addresses have the same number of failures, compare using cmp
        foreach my $ip (
            sort {
                $failed_ips{$b} <=> $failed_ips{$a}
                    ||
                $a cmp $b
            } keys %failed_ips
        ) {

            ##### Display the IP address and its failure count.
            ##### %-20s left-aligns the IP address within a 20-character
            ##### field, while %d displays the failure count as an integer.
            printf "%-20s %d\n", $ip, $failed_ips{$ip};
        }
    }

    ### Else no failed IP addresses were recorded.
    else {
        print "No failed authentication IP addresses found.\n";
    }


    ### Add a blank line before the username section.
    print "\n";


    print "Users Associated With Failures\n";
    print "----------------------------------------------------\n";

    ### Check whether the failed username hash contains any entries.
    if (%failed_users) {

        #### Iterate through the usernames after sorting them.
        #### Usernames are sorted by failure count in descending order.
        #### If two usernames have the same number of failures, they are sorted alphabetically.
        foreach my $user (
            sort {
                $failed_users{$b} <=> $failed_users{$a}
                    ||
                $a cmp $b
            } keys %failed_users
        ) {

            ##### Display the username and its failure count.
            printf "%-20s %d\n", $user, $failed_users{$user};
        }
    }

    ### No failed usernames were recorded.
    else {
        print "No failed authentication users found.\n";
    }

    ### Add a final blank line after the report.
    print "\n";

}

# Run the main program function.
runProgram();
