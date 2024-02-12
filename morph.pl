#!/usr/bin/perl -i
# -----------------------------------------------------------------------
# Intent:
#   o Update copyright notice for a named list of files.
#   o Edit files inplace.
#   o Modify copyright notice to span current year.
#   o Modify non-std notices 'Copyright (c)', *-present, etc
#     into a standard notice that spans current year.
# -----------------------------------------------------------------------
# [NOTE]
#   - Print messages to STDERR else they become part of file edits
# -----------------------------------------------------------------------
# [TODO]
#   - Copyright edits target ONF copyright notices.
#   - Logic can be genralized through the use of config files:
#       - templates
#       - search strings
#       - rewrite rules (normalize variations)
# -----------------------------------------------------------------------

##--------------------##
##---]  INCLUDES  [---##
##--------------------##
use strict;
use warnings;

##-------------------##
##---]  GLOBALS  [---##
##-------------------##
my @now = localtime;
my $year = 1900 + $now[5];

my $debug = 1;

## -----------------------------------------------------------------------
## Intent: Extract start date from a given string (~copyright notice)
## -----------------------------------------------------------------------
## Given:
##   scalar   A string to extract start date from.
## Return (in context):
##   scalar - start date
##   array  - A list containing start date.
## -----------------------------------------------------------------------
sub get_start_date
{
    my $line = join('', @_);
    my @range = $line =~ /(\d{4})/; # extract start date
    wantarray ? @range : $range[0];
}

## -----------------------------------------------------------------------
## Intent: Given a copyright date insert ending date or create a range
## Given: (one of)
##   null    Date range is the current year
##   scalar  Create a date range that may span current year
##   array   Create a date range that spans the current year.
## Returns (in context):
##   array  - start and end copyright notice range
##   scalar - notice range formatted as start-end
## -----------------------------------------------------------------------
sub gen_range
{
    my $raw = join(' ', @_);
    my @range = get_start_date($raw);

    push(@range, $year) if (0 == scalar(@range));  # Bad syntax or new
    push(@range, $year) if ($range[0] != $year);   # Create a span

    print STDERR "WARNING: Copyright date is wonky \@range=(@range)\n"
        if (scalar(@range) > 1 && ($range[0] > $range[1]));

    wantarray ? @range : join('-', @range);
}

## -----------------------------------------------------------------------
## Intent: Preserve string prefix for a line (comments, indentation, etc).
##   Return copyright notice string with date substitution.
## -----------------------------------------------------------------------
sub notice
{
    my $line = join(' ', @_);

    my $range = gen_range($line);

    my @buffer = ('Copyright');
    push(@buffer, $range);         
    push(@buffer, 'Open Networking Foundation Contributors');
    return join(' ', @buffer);
}

## -----------------------------------------------------------------------
## Intent: Given a line containing an ONF copyright notice, replace the
##   notice with a standard copyright string that spans current year.
## -----------------------------------------------------------------------
sub replace_copyright
{
    my ($line, @range) = @_;
    my $copyright = notice(@range);

    my $loc = index($line, 'opyright');
    substr($line, $loc-1, length($line), $copyright);
    return $line;
}

## -----------------------------------------------------------------------
## Intent: Update format and copyright range for SPDX notice.
## -----------------------------------------------------------------------
sub spdx_notice
{
    my ($line) = @_; 
    my ($keyword) = split(/:/, $line);
    my $copyright = notice($line);

    $copyright =~ s/^Copyright\s+//;
    $line = sprintf("%s: %s\n", $keyword, $copyright);
    return $line;
}

##----------------##
##---]  MAIN  [---##
##----------------##
 LINE:
while (<>)
{
    my $line = $_;
    my $minimalist_rewrite = 0;

    ## -------------------------------------------
    ## Ignore source and non-ONF copyright notcies
    ## -------------------------------------------
    if (!/copyright/oi)
    {
        print $_;
        next LINE;
    }

    ## -------------------------------
    ## Ignore non-ONF copyright notice
    ## -------------------------------
    elsif ( 1
            && !/Open\s+Networking\s+Foundation/oi
            && !/ONF Contributors/oi
       )
    {
        print $_;
        next LINE;
    }

    ## -------------------------------------
    ## Special case and mutant rewrite rules
    # SPDX-FileCopyrightText: 2023-2024 Open Networking Foundation Contributors
    ## -------------------------------------
    if (/SPDX\-FileCopyrightText:/o)
    {
        print STDERR "RULE[1]: $line" if ($debug);
        $line = spdx_notice($line);
        print STDERR "REPL[1]: $line" if ($debug);
        print $line;
        next LINE;
    }
    # ---------------------------------------------------
    # Copyright (c) Open Networking Foundation
    #   - Change non-standard notice into standard.
    # ---------------------------------------------------
    elsif (/Copyright\s*\(c\)/oi)
    {
        print STDERR "RULE[2]: $line" if ($debug);
        $minimalist_rewrite = 1;
    }
    # -----------------------------------------------------------------------
    # Well formatted: Rewrite notice normalizing variants:
    #   - Standard notice in comment header.
    #   - Accommodate notice inlined as quoted source strings.
    #   - Locate and rewrite notice inline.
    # -----------------------------------------------------------------------
    # Copyright {range} Open Networking Foundation Contributors
    # Copyright 2024 Open Networking Foundation (ONF) and the ONF Contributors
    # Copyright 2017-2024 Open Networking Foundation (ONF) and the ONF Contributors
    # -----------------------------------------------------------------------
    elsif (my ($matched) = $line =~ m{
            (
              Copyright
              .+
              \s+
              (?:ONF|Foundation)
              \s+ 
              Contributors
            )
           }oisx)
        # ----------------------------------------------
        # https://perldoc.perl.org/perlre#%2Fx-and-%2Fxx
        # ----------------------------------------------
        # o - compile regex once VS every iteration
        # i - case insensitive
        # s - regex is a single line for pattern matching
        # x - write regex across multiple lines
        # ----------------------------------------------
    {
        my $start = index($line, $matched);
        my $copyright = notice($matched);

        print STDERR "RULE[3]: $line" if ($debug);
        substr($line, $start, length($matched), $copyright);
        print STDERR "REPL[3]: $line" if ($debug);
        
        $_ = $line;
    }

    else
    {
        print STDERR "RULE[4]: $line" if ($debug);
        $minimalist_rewrite = 1;
    }
    
    # -----------------------------------------------------------------------
    # We are off in the weeds so be very careful:
    #   - General format of an ONF copyright notice
    #   - Invalid format due to typo(s) ?
    #   - Minimalist approach: update limited to date range.
    # -----------------------------------------------------------------------
    if ($minimalist_rewrite)
    {
        # Special snowflake
        print STDERR "RULE[1d]: $line" if ($debug);
        print STDERR "** Detected a special snowflake: enable minimal rewrite\n";
        print STDERR "** Update script to detect and rewrite this case.\n";

        my ($matched) = $line =~ m{ (\d+-?\d*) }oisx;

        my $start = index($line, $matched);
        my $range = gen_range($matched);

        print STDERR "RULE[A]: $line" if ($debug);
        substr($line, $start, length($matched), $range);
        print STDERR "REPL[A]: $line" if ($debug);

        $_ = $line;
    }

    print; # 
}

# Copyright 2019-2024 Open Networking Foundation (ONF) and the ONF Contributors

# [EOF]
