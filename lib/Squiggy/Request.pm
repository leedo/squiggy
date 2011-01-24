package Squiggy::Request;

use parent 'Plack::Request';

sub new {
  my($class, $env, $cb) = @_;

  Carp::croak(q{$env is required})
    unless defined $env && ref($env) eq 'HASH';
  Carp::croak(q{$cb is required})
    unless defined $cb && ref($cb) eq 'CODE';

  bless { env => $env, cb => $cb }, $class;
}

sub new_response {
  my $self = shift;
  Squiggy::Response->new($self->{cb});
}

1;
