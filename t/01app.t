use Test::More tests => 2;
BEGIN { use_ok( Catalyst::Test, 'Freelex' ); }

ok( request('/')->is_success );
