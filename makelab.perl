#!/usr/bin/perl -w

$size = shift;
$size = 1024 if (!$size);

for ($i=0; $i < $size; $i++) {
  print join("\t", "symbol$i", $i), "\n";
}
