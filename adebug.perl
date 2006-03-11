#!./dddperl -wd

use lib qw(./blib/lib ./blib/arch);
use Gfsm;

sub test1 {
  our $labs = Gfsm::Alphabet->new;
  our $key = 'a';
  our $lab = $labs->get_label($key);
  print "lab($key)=$lab\n";
}

sub test2 {
  our $labs = Gfsm::Alphabet->new;
  #our $av = $labs->_av;
  #our $hv = $labs->_hv;

  #$labs->insert($_) foreach (qw(<eps> a b c));
  $labs->insert('<eps>',0);
  $labs->_debug();

  #$labs->remove_label(2);
  #$labs->_debug;

  #$labs->remove_label(0);
}
#test2;

sub test2b {
  test2;
  $labs->insert('foo',0);
  $labs->_debug;
}

sub test3 {
  our $labs = Gfsm::Alphabet->new;
  $labs->insert($_) foreach (qw(<eps> a b c));
  our @l = qw(<eps> a b c);

  $labs->_debug;
  #$labs->_debugl();
}
#test3;

sub test3b {
  our $labs = Gfsm::Alphabet->new;
  our $labs1 = Gfsm::Alphabet->new;
  $labs->insert($labs1);
}

sub test4 {
  our $labs = Gfsm::Alphabet->new();
  eval("\$labs->insert('$_');") foreach (qw(<eps> a b c));
  $labs->_debug;
}
test4;

foreach $i (0..5) {
  print "--dummy[$i]--\n";
}
