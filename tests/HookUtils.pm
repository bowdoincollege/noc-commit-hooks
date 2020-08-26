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
my $output;
my $stderr;

# run a hook script with varied input
# test exit value and all combinations of --fix/--nofix and --color/nocolor
sub test_script {
  $S = shift;
  my $valid   = shift;
  my $invalid = shift;

  script_compiles($S);
  script_runs([ $S, '/tmp/nonexistent', '/dev/null' ], 'multiple file args');
  script_runs($S, { exit => 1 }, 'no args');
  run_fail('invalid args', '', args => ['--not-implemeted']);

  # check valid entries individually
  for (@$valid) {
    my $c = 'valid';
    run($c, $_);
    output_is($_, "$c no change");
    stderr_unlike($ANSI_escape, "$c no color");
  }

  # check valid entries together
  {
    my $c  = 'valids';
    my $in = join("\n", @$valid);
    run($c, $in);
    output_is($in, "$c no change");
    stderr_unlike($ANSI_escape, "$c no color");
  }

  # check invalid entries individually
  for (@$invalid) {
    my $c;

    # normal (nofix is default)
    $c = 'invalid';
    run_fail($c, $_->[0], args => ['--color']);
    output_is($_->[0], "$c no change");
    stderr_like($ANSI_escape, "$c color");

    # normal with explicit nofix
    $c = 'invalid nofix';
    run_fail($c, $_->[0], args => [ '--color', '--nofix' ]);
    output_is($_->[0], "$c no change");
    stderr_like($ANSI_escape, "$c color");

    # fix
    $c = 'invalid fix';
    run_fail($c, $_->[0], args => [ '--color', '--fix' ]);
    output_is($_->[1], "$c fixed");
    stderr_like($ANSI_escape, "$c color");

    # without terminal
    $c = 'invalid noterm';
    run_fail($c, $_->[0], args => ['--nocolor']);
    output_is($_->[0], "$c no change");
    stderr_unlike($ANSI_escape, "$c no color");

    # without terminal and explicit nofix
    $c = 'invalid noterm nofix';
    run_fail($c, $_->[0], args => [ '--nocolor', '--nofix' ]);
    output_is($_->[0], "$c no change");
    stderr_unlike($ANSI_escape, "$c no color");

    # fix without terminal
    $c = 'invalid noterm fix';
    run_fail($c, $_->[0], args => [ '--nocolor', '--fix' ]);
    output_is($_->[1], "$c fixed");
    stderr_unlike($ANSI_escape, "$c no color");

  }

  # check invalid entries together
  {
    my $c   = 'valids fix';
    my $in  = join("\n", map { $_->[0] } @$invalid);
    my $out = join("\n", map { $_->[1] } @$invalid);
    run_fail($c, $in, args => [ '--color', '--fix' ]);
    output_is($out, "$c fixed");
    stderr_like($ANSI_escape, "$c color");
  }

}

# helper function to run script and output (possibly modified) input file and stderr
sub run {
  my $check = shift;
  my $input = shift;
  my %opt = (args => [],
             exit => 0,
             @_
            );

  my ($ifh, $ifn) = tempfile(DIR => $DIR);
  print $ifh $input;

  script_runs([ $S, @{ $opt{'args'} }, $ifn ],
              { exit => $opt{'exit'}, stderr => \$stderr },
              $check
             );

  open F, "<$ifn";
  my $o = $output = do { local $/; <F> };
}

sub run_fail {
  run(@_, exit => 1);
}

sub output_is {
  my ($match, $check) = @_;
  is($output, $match, $check);
}

sub stderr_like {
  my ($match, $check) = @_;
  like($stderr, $match, $check);
}

sub stderr_unlike {
  my ($match, $check) = @_;
  unlike($stderr, $match, $check);
}

1;
