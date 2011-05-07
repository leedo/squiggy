package Squiggy::Request;

use Encode;
use parent 'Plack::Request';

sub new {
  my ($class, %args) = @_;

  Carp::croak(q{env is required})
    unless defined $args{env} && ref($args{env}) eq 'HASH';
  Carp::croak(q{cb is required})
    unless defined $args{cb} && ref($args{cb}) eq 'CODE';
  Carp::croak(q{captures is required})
    unless defined $args{captures} && ref($args{captures}) eq 'HASH';

  bless \%args, $class;
}

sub query_parameters {
  my $self = shift;

  $self->env->{'plack.request.query'} ||= do {
    my %params   = $self->uri->query_form;
    my $encoding = $self->content_encoding || "utf8";

    Hash::MultiValue->new(
      map {$_ => decode($encoding, $params{$_})}
      keys %params
    );
  };
}

sub body_parameters {
  my $self = shift;

  unless ($self->env->{'plack.request.body'}) {
    $self->_parse_request_body;

    my $params   = $self->env->{'plack.request.body'};
    my $encoding = $self->content_encoding || "utf8";

    for my $key ($params->keys) {
      my @values = $params->get_all($key);
      $params->remove($key);
      $params->set($key, decode($encoding, $_)) for @values;
    }
  }

  return $self->env->{'plack.request.body'};
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
