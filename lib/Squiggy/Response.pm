package Squiggy::Response;
use parent 'Plack::Response';

sub new {
  my($class, $cb) = @_;

  Carp::croak(q{$cb is required})
    unless defined $cb && ref($cb) eq 'CODE';

  my $self = bless {cb => $cb}, $class;
  $self->status(200);
  $self->content_type("text/html");

  $self;
}

sub send {
  my ($self, $body) = @_;

  die "sending on a closed response" if $self->{closed};
  die "sending on a streaming response" if $self->{writer};

  $self->body($body) if defined $body;
  $self->content_length(length $self->body);
  
  $self->{cb}->($self->SUPER::finalize);
  $self->{closed} = 1;
}

sub write {
  my ($self, $chunk) = @_;

  die "writing on a closed response" if $self->{closed};

  if (!$self->{writer}) {
    my $res = $self->SUPER::finalize;
    $self->{writer} = $self->{cb}->([@$res[0,1]]);
    $self->{writer}->write(join "", @{$res->[2]})
      if $res->[2] and ref $res->[2] eq "ARRAY";
  }
  
  $self->{writer}->write($chunk);
}

sub close {
  my $self = shift;

  if ($self->{writer}) {
    $self->{writer}->close;
  }

  $self->{closed} = 1;
}

1;
