package HookUtils;
use strict;
use warnings;
use Test::Script;
use Test::More qw(no_plan);
use File::Temp qw(tempdir tempfile);

use Exporter qw(import);
our @EXPORT_OK = qw(test_script);

my $DIR         = tempdir(CLEANUP => 1);
my $ANSI_escape = qr/\e\[[0-9;]*m/;
my $S;

# run a hook script with varied input
# test exit value and all combinations of --fix/--nofix and --color/nocolor
sub test_script {
  $S = shift;
  my $valid   = shift;
  my $invalid = shift;

  script_compiles($S);
  script_runs([ $S, '/tmp/nonexistent', '/dev/null' ], 'multiple file args');
  script_runs($S, { exit => 1 }, 'no args');
  run_fails('invalid args', '', ['--not-implemeted']);

  # check valid entries individually
  for (@$valid) {
    my $c = 'valid';
    my ($o, $e) = run($c, $_);
    is($o, $_, "$c no change");
    unlike($e, $ANSI_escape, "$c no color");
  }

  # check valid entries together
  {
    my $c  = 'valids';
    my $in = join("\n", @$valid);
    my ($o, $e) = run($c, $in);
    is($o, $in, "$c no change");
    unlike($e, $ANSI_escape, "$c no color");
  }

  # check invalid entries individually
  for (@$invalid) {
    my ($c, $o, $e);

    # normal (nofix is default)
    $c = 'invalid';
    ($o, $e) = run_fails($c, $_->[0], ['--color']);
    is($o, $_->[0], "$c no change");
    like($e, $ANSI_escape, "$c color");

    # normal with explicit nofix
    $c = 'invalid nofix';
    ($o, $e) = run_fails($c, $_->[0], [ '--color', '--nofix' ]);
    is($o, $_->[0], "$c no change");
    like($e, $ANSI_escape, "$c color");

    # fix
    $c = 'invalid fix';
    ($o, $e) = run_fails($c, $_->[0], [ '--color', '--fix' ]);
    is($o, $_->[1], "$c fixed");
    like($e, $ANSI_escape, "$c color");

    # without terminal
    $c = 'invalid noterm';
    ($o, $e) = run_fails($c, $_->[0], ['--nocolor']);
    is($o, $_->[0], "$c no change");
    unlike($e, $ANSI_escape, "$c no color");

    # without terminal and explicit nofix
    $c = 'invalid noterm nofix';
    ($o, $e) = run_fails($c, $_->[0], [ '--nocolor', '--nofix' ]);
    is($o, $_->[0], "$c no change");
    unlike($e, $ANSI_escape, "$c no color");

    # fix without terminal
    $c = 'invalid noterm fix';
    ($o, $e) = run_fails($c, $_->[0], [ '--nocolor', '--fix' ]);
    is($o, $_->[1], "$c fixed");
    unlike($e, $ANSI_escape, "$c no color");

  }

  # check invalid entries together
  {
    my $c   = 'valids fix';
    my $in  = join("\n", map { $_->[0] } @$invalid);
    my $out = join("\n", map { $_->[1] } @$invalid);
    my ($o, $e) = run_fails($c, $in, [ '--color', '--fix' ]);
    is($o, $out, "$c fixed");
    like($e, $ANSI_escape, "$c color");
  }
}

# helper function to run script and output (possibly modified) input file and stderr
sub run {
  my $check = shift;
  my $input = shift;
  my $args  = shift || [];
  my $exit  = shift || 0;
  my $e;

  my ($ifh, $ifn) = tempfile(DIR => $DIR);
  print $ifh $input;

  script_runs([ $S, @$args, $ifn ], { exit => $exit, stderr => \$e }, $check);

  open F, "<$ifn";
  my $o = do { local $/; <F> };

  return ($o, $e);
}

sub run_fails {
  run(@_, 1);
}

1;
