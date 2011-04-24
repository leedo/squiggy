package Squiggy;

use Squiggy::Request;
use Squiggy::Response;
use Router::Simple;

use strict;
use warnings;

use base "Exporter";
our @EXPORT = qw/get post any timer/;
our %routers;

sub router {
  my $package = shift;
  $routers{$package} ||= Router::Simple->new
}

sub to_psgi {
  my $package = $_[0] || caller(0);
  my $router = router $package;

  my $app = sub {
    my $env = shift;
    if (my $p = $router->match($env)) {
      return sub {
        my $respond = shift;
        my $cb = delete $p->{code};
        my $req = Squiggy::Request->new($env, $respond, $p);
        my $res = $req->new_response(200);
        $cb->($req, $res);
      };
    }
    else {
      return [404, [], ['not found']];
    }
  };

  Plack::Middleware::WebSocket->wrap($app);
}

sub add_route {
  my ($method, $package, $route, $sub) = @_;
  my $router = router $package;

  $router->connect($route,
    { code => $sub },
    { method => $method },
  );

  to_psgi $package; 
}

for my $method (qw/get post any/) {
  no strict;
  *{__PACKAGE__."::$method"} = sub {
    my $package = caller(0);
    add_route uc $method, $package, @_;
  };
}

1;
