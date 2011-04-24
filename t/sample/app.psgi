use Squiggy;
use AnyEvent;

get "/index" => sub {
  my ($req, $res) = @_;
  my $t; $t = AE::timer 0.5, 0, sub {
    $res->send("hi there");
    undef $t;
  };
};

get "/writer" => sub {
  my ($req, $res) = @_;

  my $limit = 10;
  my $t; $t = AE::timer 0, 0.1, sub {
    if ($limit-- > 0) {
      $res->write($limit);
    }
    else {
      $res->close;
      undef $t;
    }
  };
};

get "/{id:[0-9]+}" => sub {
  my ($req, $res) = @_;

  $res->send($req->captures->{id});
};
