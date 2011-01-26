package Squiggy::Request;

use parent 'Plack::Request';

sub new {
  my($class, $env, $cb, $cap) = @_;

  Carp::croak(q{$env is required})
    unless defined $env && ref($env) eq 'HASH';
  Carp::croak(q{$cb is required})
    unless defined $cb && ref($cb) eq 'CODE';
  Carp::croak(q{$captures is required})
    unless defined $cap && ref($cap) eq 'HASH';

  bless { env => $env, cb => $cb, captures => $cap }, $class;
}

sub new_response {
  my $self = shift;
  Squiggy::Response->new($self->{cb});
}

sub captures {
  my $self = shift;
  return $self->{captures}
}

1;
