#!/usr/bin/perl -i
# -----------------------------------------------------------------------
# Intent:
#   o Update copyright notice for a named list of files.
#   o Edit files inplace.
#   o Modify copyright notice to span current year.
#   o Modify non-std notices 'Copyright (c)', *-present, etc
#     into a standard notice that spans current year.
# -----------------------------------------------------------------------
    
use strict;
use warnings;

my @now = localtime;
my $year = 1900 + $now[5];

## -----------------------------------------------------------------------
## Intent: Preserve string prefix for a line (comments, indentation, etc).
##   Return copyright notice string with date substitution.
## -----------------------------------------------------------------------
sub notice
{
    my @range = @_;
    my @buffer = ('Copyright');
    push(@buffer, @range);
    push(@buffer, 'Open Networking Foundation (ONF) and the ONF Contributors');
    push(@buffer, '\n');
    return join(' ', @buffer);
}

## -----------------------------------------------------------------------
## Intent: Given a line containing an ONF copyright notice, replace the
##   notice with a standard copyright string that spans current year.
## -----------------------------------------------------------------------
sub replace_copyright
{
    my ($line, @range) = @_;

    my $loc = index($line, 'opyright');
    substr($line, $loc-1, length($line), notice($start));
    return $line;
}

 LINE:
while (<>)
{
    my $line = $_;

    # ----------------
    # performance skip
    # ----------------
    if (!/copyright/oi)
    {
        print $_;
        next LINE;
    }

    # ---------------------------------------------------
    # Copyright (c) 2011, 2012 Open Networking Foundation
    #   - Change non-standard notice into standard.
    # ---------------------------------------------------
    if (!/Copyright\s*\(c\)/oi) {}
    elsif ($line =~ /Open\s+Networking\s+Foundation/oi) {
        my ($start) = $line =~ /(\d{4})/;

        $line = replace_copyright($line, $start);
        print $line;
        next LINE;
    }
    
    # ----------------------------------------
    # Augment ending date to span current year
    # ----------------------------------------
    if (my ($val) = m/Copyright (.+) Open Networking Foundation/)
    {
        my $loc = index($line, $val);
        my $len = length($val);
        $val =~ s/\s+//;

        my @fields = split(/-/, $val);
        if (2 > 0+@fields)
        {
            next LINE if ($fields[0] > $year); # End date is wonky (year > now)
            push(@fields, $year) if ($fields[0] != $year);
        }
        else
        {
            pop(@fields);
            push(@fields, $year);
        }

        my $span = join('-', @fields);
        $span = $year if ($span eq "$year-$year"); # {year}-present
        $_ = replace_copyright($line, $start);
    }

    print;
}

# Copyright 2019-2023 Open Networking Foundation (ONF) and the ONF Contributors

# [EOF]
