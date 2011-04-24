use Test::More;
use Plack::Test;
use Plack::Util;
use HTTP::Request::Common;
use AnyEvent;

use strict;
use warnings;

$Plack::Test::Impl = "Server";
my $app = Plack::Util::load_psgi("t/sample/app.psgi");

test_psgi(
  $app,
  sub {
    my $cb = shift;
    my $req = GET "http://localhost/writer";
    my $res = $cb->($req);
    is $res->code, 200;
    is $res->content, "9876543210";
  }
);

test_psgi(
  $app,
  sub {
    my $cb = shift;
    my $req = GET "http://localhost/writer_body";
    my $res = $cb->($req);
    is $res->code, 200;
    is $res->content, "initial body9876543210";
  }
);

done_testing();
