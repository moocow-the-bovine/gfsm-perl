#!/usr/bin/perl -w

$maxi = shift;
$maxi = 128 if (!$maxi);
foreach $i (0..($maxi-1)) {
  print join("\t", $i, $i+1, $i, $i+1), "\n", $i, "\n";
}
print $maxi, "\n";
