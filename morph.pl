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
    return join(' ', @buffer) . "\n";
}

## -----------------------------------------------------------------------
## Intent: Given a line containing an ONF copyright notice, replace the
##   notice with a standard copyright string that spans current year.
## -----------------------------------------------------------------------
sub replace_copyright
{
    my ($line, @range) = @_;

    my $loc = index($line, 'opyright');
    my $span = join('-', @range);

    substr($line, $loc-1, length($line), notice($span));
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
    # Copyright (c) Open Networking Foundation
    #   - Change non-standard notice into standard.
    # ---------------------------------------------------
    if (!/Copyright\s*\(c\)/oi) {}
    elsif ($line =~ /Open\s+Networking\s+Foundation/oi) {
        my @range = $line =~ /(\d{4})/;
        if ($range[0] != $year)
        {
            # Create a range from single legacy date
            push(@range, $year);
        }
        $line = replace_copyright($line, @range);
        print $line;
        next LINE;
    }

    # -------------------------------------------------------------------------------------------
    # SPDX-FileCopyrightText: 2023-2024 Open Networking Foundation (ONF) and the ONF Contributors
    # -------------------------------------------------------------------------------------------
    if (my ($span) = /SPDX-FileCopyrightText: .*(\d{4}) Open Networking Foundation/i)
    {
        my @range = ($span);
        push(@range, $year) if ($range[0] ne $year);

        my $loc = index($line, 'SPDX-FileCopyrightText');
        my $span = join('-', @range);
        my $notice = notice($span);
        substr($notice, 0, length('Copyright'), 'SPDX-FileCopyrightText:');
        substr($line, $loc, length($line), $notice);
        print $line;
        next LINE;
    }

    # ----------------------------------------
    # Augment ending date to span current year
    # ----------------------------------------
    if (my ($val) = m/Copyright (.+) Open Networking FOundation/)
    {
        my $loc = index($line, $val);
        my $len = length($val);

        my ($start) = $val =~ /(\d{4})/;
        next LINE if ($start > $year); # Notice date is wonky (year > now)

        my @fields = ($start);
        push(@fields, $year) if ($fields[0] ne $year);

        my $span = join('-', @fields);
        $_ = replace_copyright($line, $span);
    }

    print;
}

# Copyright 2019-2024 Open Networking Foundation (ONF) and the ONF Contributors

# [EOF]
