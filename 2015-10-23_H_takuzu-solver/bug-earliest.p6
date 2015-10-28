use Test;
for 1,1,2,2 -> $num, $value {
  say "top for loop " ~  "value($value) from channel is num($num)";
  my $c = Channel.new;
  my $p = start { $c.send($value) };
  my $r = start {
    await $p;
    $c.close;
  };
  loop {
    say "top loop " ~  "value($value) from channel is num($num)";
    earliest $c {
      more * {
        say "top more " ~  "value($value) from channel is num($num)";
        is $_, $num, "value($value) from channel is num($num)";
      }
      done * { last }
    }
  }
  await $r;
}
done-testing;
