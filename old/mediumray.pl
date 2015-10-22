use strict;
# 'strict' forces you to declare your variables with either 'my' for
# lexical scope or 'our' for package global scope.  This allows perl
# to check for various things, most usefully it catches typos.  If you
# had accidentally typed '$roomNumbr' with 'strict' on perl would complain
# that it didn't know the variable, without 'strict' it would just treat it
# as a new variable set to 'undef' and you'd be tracking down why your code
# wasn't working until you found that misspelt variable.

use warnings;
# Turns on additional warnings like printing an undefined variable, etc.
# Sometimes you want this, sometimes you don't, but it's best to start with
# it on and disable it for small sections of code where you just don't care.

#use diagnostics;
# You can use 'diagnostics' like this, but mostly shouldn't leave it in for
# production code.  There's a large overhead loading all of those messages.
# Just as easy to use '-Mdiagnostics' on the command line when needed.


#open(INPUT_FILE, $ARGV[0]) or die $!;
open my $INPUT_FILE, '<', $ARGV[0] or die $!;
# Use 'my' for a lexical filehandle instead of a GLOBAL SYMBOL.
# And use the 3-arg form of 'open'.  The 2-arg 'open' is old and powerful,
# but almost too powerful.  You can do things like:
#
# open my $fh, 'ps |';  # to open a system command which is nice,
# but when you let the user give you the filename and they can do something
# like 'yourprogram "rm -rf /; echo gotcha|"'
#
# You can still do pipe open and other neater stuff with the 3-arg version
# but it's a bit safer.  There's plenty of docs out there for 3-arg open.


#Initialise for readability - nested hash tables will hold room data
my $roomStuff = {};
# Using 'my' again for a lexical variable, we'll do this for all of them.

while(<$INPUT_FILE>)  # just need to use our $INPUT_FILE instead of INPUT_FILE
{
#chomp;  # don't need, you'll use a regex to extract digits only, no need to
         # chomp newlines

#my $line = $_;  # don't really need either, only use it once in the regex,
                 # and $_ is the default target for regex matching anyway.

    #we parse the line coming in. If it matches the regex, the values are passed on and used
    if(my ($visNumber, $roomNumber, $inOrOut, $time) = m/^(\d+)\s(\d+)\s(\w)\s(\d+)/)
    # that matches $_ automatically.  You might make the regex easier to
    # read by using the /x modifier and adding whitespace, but that's more
    # important for more hairy matches.
    #  =~ m/ ^ (\d+) \s (\d+) \s (I|O) \s (\d+) /x ...
    #
    #  In later perls (>= 5.10 I think, maybe 5.12) you can go wild and
    #  use named captures.
    #
    #  if(m/ ^
    #       (?<visNumber> \d+)
    #       \s
    #       (?<roomNumber> \d+)
    #       ...
    #   /x) {
    #       # the %+ hash contains the matches so...
    #       # $+{visNumber}  , $+{roomNumber} , ... has your data
    #
    # Enough rabbit chasing.
 
    {
        #if our visitor is going in to the room, this will be true
        #my $visitorGoingIn=($inOrOut =~ /^I$/);
        my $visitorGoingIn = $inOrOut eq 'I';  # no regex needed.

        #So our visitor is going in, put the time he went in at in a hash table with relevant data.
        #If not going in, then add the time he has spent in that room to his own hash table. Need to count the min he left too, so +1
        if($visitorGoingIn)
        # I'd have just: if($inOrOut eq 'I') ... here, but that's just 
        # nitpicky.  It's good that you're naming things so well.
        {
            #$roomStuff->{$roomNumber}->{$visNumber}->{"timeEntered"} = $time;
            $roomStuff->{$roomNumber}{$visNumber}{timeEntered} = $time;
            # you only need to use '->' to deref the very first reference,
            # after that they can be ommited.  Don't need the quotes in hash
            # keys most of the time if you want to save more typing.
        }
        else
        {
            $roomStuff->{$roomNumber}{$visNumber}{totalTime} += $time - $roomStuff->{$roomNumber}{$visNumber}{timeEntered} + 1;  # eww parenthesis! :)
        }
    }
}

#now we print out the data we want - sort the tables by room number, loop through rooms and visitors
#foreach my $roomNumber (sort {$a <=> $b} (keys (%$roomStuff)))
for my $roomNumber (sort {$a <=> $b} keys %$roomStuff)
# 'for' and 'foreach' are *exactly* the same, so it's personal preference,
# just if you ever read somewhere that you need to use one or the other for
# something to work... you don't.
#
# Notice that you don't have a 'my ($a,$b)' or 'our ($a,$b)' anywhere?
# $a and $b are magically 'our' variables because they are used in
# 'sort' blocks.  You can still use 'my ($a,$b)' or just $a and $b in your
# own code, just be a bit wary.

{
    foreach my $visitor (keys %{$roomStuff->{$roomNumber}})
    # too many parens and that hash deref thing.
    {
        $roomStuff->{$roomNumber}{timeByAll} += $roomStuff->{$roomNumber}{$visitor}{totalTime};
        $roomStuff->{$roomNumber}{numberVisited}++;
    }

    my $timeByAll      = $roomStuff->{$roomNumber}{timeByAll};
    my $numberVisited  = $roomStuff->{$roomNumber}{numberVisited};

    printf "Room %i, %i minute average visit, %i visitor(s) total\n", $roomNumber, int($timeByAll/$numberVisited), $numberVisited;
}

#http://onyxneon.com/books/modern_perl/
#http://modernperlbooks.com/books/modern_perl/chapter_00.html

