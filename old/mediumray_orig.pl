open(INPUT_FILE, $ARGV[0]) or die $!;

#Initialise for readability - nested hash tables will hold room data
$roomStuff = {};

while(<INPUT_FILE>)
{
chomp;
$line = $_;

    #we parse the line coming in. If it matches the regex, the values are passed on and used
    if(($visNumber, $roomNumber, $inOrOut, $time) = $line =~ m/^(\d+)\s(\d+)\s(\w)\s(\d+)/)
    {
        #if our visitor is going in to the room, this will be true
        $visitorGoingIn=($inOrOut =~ /^I$/);

        #So our visitor is going in, put the time he went in at in a hash table with relevant data.
        #If not going in, then add the time he has spent in that room to his own hash table. Need to count the min he left too, so +1
        if($visitorGoingIn)
        {
            $roomStuff->{$roomNumber}->{$visNumber}->{"timeEntered"} = $time;
        }
        else
        {
            $roomStuff->{$roomNumber}->{$visNumber}->{"totalTime"} += ($time - $roomStuff->{$roomNumber}->{$visNumber}->{"timeEntered"} + 1);
        }
    }
}

#now we print out the data we want - sort the tables by room number, loop through rooms and visitors
foreach $roomNumber (sort {$a <=> $b} (keys (%$roomStuff)))
{
    foreach $visitor ((keys (%$roomStuff->{$roomNumber})))
    {
        $roomStuff->{$roomNumber}->{"timeByAll"} += $roomStuff->{$roomNumber}->{$visitor}->{"totalTime"};
        $roomStuff->{$roomNumber}->{"numberVisited"}++;
    }

    $timeByAll      = $roomStuff->{$roomNumber}->{"timeByAll"}; 
    $numberVisited  = $roomStuff->{$roomNumber}->{"numberVisited"}; 

    printf "Room %i, %i minute average visit, %i visitor(s) total\n", $roomNumber, int($timeByAll/$numberVisited), $numberVisited;
}