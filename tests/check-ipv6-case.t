use strict;
use warnings;
use lib       qw(tests);
use HookUtils qw( test_script );

test_script(
  'hooks/check-ipv6-case.pl',
  [ '2001:db8::abcd',
    '2001:db8::',
  ],
  [
    # one error
    [ '2001:db8::ABCD', '2001:db8::abcd' ],

    # multiple errors
    [ '2001:DB8::ABCD', '2001:db8::abcd' ],

    # multiple IPs, first is errored
    [ '2001:db8::ABCD 2001:db8::abcd',
      '2001:db8::abcd 2001:db8::abcd',
    ],

    # multiple IPs, second is errored
    [ '2001:db8::abcd 2001:db8::ABCD',
      '2001:db8::abcd 2001:db8::abcd',
    ],

    # multiple IPs, both errored
    [ '2001:db8::ABCD 2001:db8::ABCD',
      '2001:db8::abcd 2001:db8::abcd',
    ],
  ]
);
