#!/usr/bin/perl -w

$size = shift;
$size = 1024 if (!$size);

for ($i=1; $i < $size; $i++) {
  print
    (join("\t", $i-1, $i, $i, $i, 0), "\n",
     join("\t", $i, 0), "\n",
    );
}
