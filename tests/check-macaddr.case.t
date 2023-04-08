use strict;
use warnings;
use lib       qw(tests);
use HookUtils qw( test_script );

test_script(
  'hooks/check-macaddr-case.pl',
  [ '00:00:5e:00:53:ab',
    '00:00:5e:00:53:ab  00:00:5e:00:53:cd',
  ],
  [
    # one error
    [ '00:00:5e:00:53:AB', '00:00:5e:00:53:ab' ],
    # multiple errors
    [ '00:00:5E:00:53:AB', '00:00:5e:00:53:ab' ],
    # multiple MACs, first is errored
    [ '00:00:5e:00:53:AB 00:00:5e:00:53:cd',
      '00:00:5e:00:53:ab 00:00:5e:00:53:cd',
    ],
    # multiple MACs, second is errored
    [ '00:00:5e:00:53:ab 00:00:5e:00:53:CD',
      '00:00:5e:00:53:ab 00:00:5e:00:53:cd',
    ],
    # multiple MACs, both errored
    [ '00:00:5e:00:53:AB 00:00:5e:00:53:CD',
      '00:00:5e:00:53:ab 00:00:5e:00:53:cd',
    ],
  ]
);
