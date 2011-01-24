use Test::More;
use Plack::Test;
use Plack::Util;
use HTTP::Request;
use AnyEvent;

use strict;
use warnings;

$Plack::Test::Impl = "Server";
my $app = Plack::Util::load_psgi("t/sample/app.psgi");

test_psgi(
  $app,
  sub {
    my $cb = shift;
    my $req = HTTP::Request->new(GET => "http://localhost/index");
    my $res = $cb->($req);
    is $res->code, 200;
    is $res->content, "hi there";
  }
);

test_psgi(
  $app,
  sub {
    my $cb = shift;
    my $req = HTTP::Request->new(GET => "http://localhost/writer");
    my $res = $cb->($req);
    is $res->code, 200;
    is $res->content, "9876543210";
  }
);


done_testing();
