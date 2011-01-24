use Squiggy;
use AnyEvent;

get "/index" => sub {
  my ($req, $res) = @_;
  my $t; $t = AE::timer 3, 0, sub {
    $res->body("hi there");
    $res->send;
    undef $t;
  };
};

get "/writer" => sub {
  my ($req, $res) = @_;

  my $writer = $res->writer;
  my $limit = 10;
  
  my $t; $t = AE::timer 0, 0.1, sub {
    if ($limit-- > 0) {
      $writer->write($limit);
    }
    else {
      $writer->close;
      undef $t;
    }
  };
};
