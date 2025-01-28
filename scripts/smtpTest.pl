#!/usr/bin/perl -w
use warnings;
use Net::SMTP;

# A simple perl script designed to test SMTP connections

# Define mailhost variables
## Fill in the definitions as needed
my $smtpServer   = 'SMTPHOST';
my $smtpPort     = PORT;
my $smtpUser     = 'SMTPUSER';
my $smtpPassword = 'SMTPUSERPASS';
my $smtpTo       = 'SMTPEMAILTO';

# Define a mailhost, set values above
$smtp = Net::SMTP->new($smtpServer,
                    Port => $smtpPort,
                    Timeout => 10,
                    Debug => 1);
die "Could not connect to server!\n" unless $smtp;

# Authorize user
$smtp->auth($smtpUser, $smtpPassword);

# Define the 'from' and 'to'
$smtp->mail($smtpUser);
$smtp->recipient($smtpTo);

# Define the email headers
## Fill in the From/To
$smtp->data;
$smtp->datasend("From: SMTPUSER\@EMAIL.COM");
$smtp->datasend("To: RECIPIENT\@EMAIL.COM");
$smtp->datasend("Subject: This is a test");
$smtp->datasend("\n");

# Define the email body
$smtp->datasend("hello world!");
$smtp->dataend;
$smtp->quit;
