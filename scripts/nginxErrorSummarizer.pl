#!/usr/bin/perl

# ------------------------------------------------------------------------------
# Script: nginxErrorChecker.pl
# Description: Parses Nginx error logs across Linux systems,
#              extracts the core error messages, and summarizes their frequency.
# ------------------------------------------------------------------------------

# Enforce good coding practices. These pragmas force you to declare variables
# and will catch common coding mistakes or uninitialized variables.
use strict;
use warnings;

# Module to parse command-line arguments (e.g., --top 20)
use Getopt::Long;

# --- Configuration & Defaults ---

# Set the default number of errors to display if the user doesn't specify
my $top_n = 10;
my $help  = 0;

# Define an array of standard Nginx log paths with wildcards.
# This ensures the script works out-of-the-box on different Linux distributions
# and catches logs for multiple virtual hosts.
my @log_patterns = (
    '/var/log/nginx/*error.log',   # Standard Nginx pattern
    '/var/log/nginx/*error_log'    # Fallback pattern
);

# --- Parse Command Line Options ---

# Map the command line flags to our Perl variables
GetOptions(
    "top=i"  => \$top_n,  # '=i' means this flag expects an integer
    "help"   => \$help,   # No equals sign means this is a boolean flag
) or die "Error in command line arguments. Run with --help for usage.\n";

# If the user asks for help, show the usage and exit cleanly (status 0)
if ($help) {
    print "Usage: $0 [--top 10]\n";
    print "  --top : Number of top errors to display (default: 10)\n";
    exit 0;
}

# --- Find & Open Log Files ---

my @found_logs;

# Loop through our predefined patterns to see what actually exists on this server
foreach my $pattern (@log_patterns) {
    # The glob() function takes a string with wildcards (like '*') and
    # returns a list of all actual filenames matching that pattern.
    push @found_logs, glob($pattern);
}

# If we didn't find any files matching our patterns, stop the script.
if (!@found_logs) {
    die "CRITICAL: No Nginx error logs found in standard nginx directories.\n";
}

# Hash (dictionary) to store our error messages as the key, and the count as the value.
my %error_counts;
my $total_files_parsed = 0;

# --- Main Parsing Logic ---

foreach my $log_file (@found_logs) {
    # File checks:
    # -f ensures it is a plain file (not a directory)
    # -r ensures the user running the script has read permissions
    next unless -f $log_file && -r $log_file;

    # Open the file for reading ('<'). If it fails, warn the user but continue
    # to the next file rather than crashing the whole script.
    open(my $fh, '<', $log_file) or warn "WARNING: Cannot open '$log_file': $!\n" and next;
    $total_files_parsed++;

    # Process the file line-by-line to keep memory usage extremely low,
    # even on multi-gigabyte log files.
    while (my $line = <$fh>) {
        chomp $line; # Remove the newline character at the end of the line

        # ----------------------------------------------------------------------
        # REGEX EXPLANATION 1: Identifying Error Lines
        # ----------------------------------------------------------------------
        # We only want actual errors, not startup notices or trace logs.
        # \[                : Match a literal opening bracket
        # (?:error|crit|alert|emerg|warn) : Match any of these severe log levels
        # \]                : Match a literal closing bracket
        # /i                : Make the match case-insensitive
        # ----------------------------------------------------------------------
        if ($line =~ /\[(?:error|crit|alert|emerg|warn)\]/i) {

            # ------------------------------------------------------------------
            # REGEX EXPLANATION 2: Stripping Metadata
            # ------------------------------------------------------------------
            # Nginx errors start with a timestamp and process info:
            # YYYY/MM/DD HH:MM:SS [Severity] PID#TID: *CID
            # We want to strip all of these off the front so we are just left
            # with the actual error message.
            #
            # ^             : Start of the string
            # \d{4}\/\d{2}\/\d{2}\s+\d{2}:\d{2}:\d{2}\s+ : Match the timestamp
            # \[\w+\]\s+    : Match the severity level in brackets
            # \d+#\d+:      : Match the PID and TID
            # (?:\s+\*\d+)? : Optionally match the Connection ID
            # \s+           : Match trailing whitespace
            # ------------------------------------------------------------------
            $line =~ s/^\d{4}\/\d{2}\/\d{2}\s+\d{2}:\d{2}:\d{2}\s+\[\w+\]\s+\d+#\d+:(?:\s+\*\d+)?\s+//;

            # ------------------------------------------------------------------
            # REGEX EXPLANATION 3: Data Normalization
            # ------------------------------------------------------------------
            # If the same error happens for 100 different client IPs, we want
            # it counted 100 times under ONE error, not 100 separate errors.
            # We strip out the specific IP addresses.
            # ------------------------------------------------------------------
            # Replace IPs with a generic placeholder
            $line =~ s/client:?\s+\d{1,3}(?:\.\d{1,3}){3}/client: [IP_REDACTED]/g;

            # Add the cleaned error message to our hash.
            # If it exists, it increments the count by 1.
            # If it doesn't exist, it creates it and sets it to 1.
            $error_counts{$line}++;
        }
    }
    # Always close file handles when done to free up OS file descriptors
    close($fh);
}

# --- Output & Formatting ---

print "\n";
print "=" x 80 . "\n";
printf " TOP %d NGINX WEB SERVER ERRORS\n", $top_n;
print "-" x 80 . "\n";
print " Parsed the following files:\n";
foreach my $file (@found_logs) {
    print "  - $file\n";
}
print "=" x 80 . "\n";
printf "%-7s | %s\n", "COUNT", "ERROR MESSAGE";
print "-" x 80 . "\n";

my $display_count = 0;

# ------------------------------------------------------------------------------
# SORTING LOGIC EXPLANATION
# ------------------------------------------------------------------------------
# We want to sort the keys of our %error_counts hash based on their values.
# The `<=>` operator (spaceship operator) compares two numbers.
# By putting `$error_counts{$b}` first, we sort in DESCENDING order (highest to lowest).
# ------------------------------------------------------------------------------
foreach my $msg (sort { $error_counts{$b} <=> $error_counts{$a} } keys %error_counts) {

    # Truncate extremely long error messages so they don't break terminal wrapping.
    # If the length is > 90 chars, cut it at 87 and append "..."
    my $display_msg = length($msg) > 90 ? substr($msg, 0, 87) . "..." : $msg;

    # Print the count (-7d means left-aligned integer, 7 spaces wide) and the message
    printf "%-7d | %s\n", $error_counts{$msg}, $display_msg;

    $display_count++;

    # Stop looping once we hit the requested number of top results
    last if $display_count >= $top_n;
}

# Provide a friendly fallback message if the logs were empty or lacked severe errors
if ($display_count == 0) {
    print " Good news! No standard errors found in the parsed logs.\n";
}
print "=" x 80 . "\n\n";
