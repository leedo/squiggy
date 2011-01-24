package Squiggy;

use Squiggy::Request;
use Router::Simple;

use base "Exporter";
our @EXPORT = qw/get post any/;
our %routers;

sub router {
  my $package = shift;
  $routers{$package} ||= Router::Simple->new
}

sub to_psgi {
  $package = $_[0] || caller(0);
  my $router = router $package;

  return sub {
    my $env = shift;
    if (my $p = $router->match($env)) {
      return sub {
        my $req = Squiggy::Request->new($env, shift);
        my $res = $req->new_response(200);
        $p->{code}->($req, $res);
      };
    }
    else {
      return [404, [], ['not found']];
    }
  };
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
  *{__PACKAGE__."::$method"} = sub {
    my $package = caller(0);
    add_route uc $method, $package, @_;
  };
}

1;
