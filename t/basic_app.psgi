use Squiggy;
use AnyEvent;

get "/index" => sub {
  my ($req, $res) = @_;
  my $t; $t = AE::timer 3, 0, sub {
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
