{
  package Data::Pointer::SCALAR;
  $VERSION	= 0.3;
  @ISA		= qw(Data::Pointer);

  push @Data::Pointer::register, __PACKAGE__;

  use strict;
  use warnings;

  sub new {
  	my $class = shift;
  	my %opts  = @_;

  	Carp::croak("oooh you've got a nerve calling me as a class method!!!")
  		if caller() ne 'Data::Pointer';

  	return _init($class, \%opts);
  }

  sub _init {
  	my($class, $opts) = @_;

  	$opts->{_isnum}	= is_numeric( value($opts) );
  	$opts->{_type}	= $opts->{_isnum} ? 'NUMBER' : 'STRING'
  		unless exists $opts->{_type};

  	return bless $opts, __PACKAGE__ . '::' . ucfirst lc $opts->{_type};
  }

  ## TODO: figure out why this is called twice (lvalue?)
  sub value : lvalue {
  	ref $_[0]->{_value} ? ${$_[0]->{_value}} : $_[0]->{_value};
  }

  ## see. http://archive.develooper.com/dbi-dev@perl.org/msg01116.html
  sub is_numeric {
  	($_[0] & ~ $_[0]) eq "0";
  }
}

{
  package Data::Pointer::SCALAR::Number;

  @ISA = qw(Data::Pointer::SCALAR);

  push @Data::Pointer::register, __PACKAGE__;

  use strict;
  use warnings;

  sub deref : lvalue {
	$_[0]->value
  }

  sub incr  { Carp::croak("can't increment pointer to a number")  }
  sub decr  { Carp::croak("can't increment pointer to a number")  }
  sub plus  { Carp::croak("can't increment pointer to a number")  }
  sub minus { Carp::croak("can't increment pointer to a number")  }
}

{
  package Data::Pointer::SCALAR::String;

  @ISA = qw(Data::Pointer::SCALAR);

  push @Data::Pointer::register, __PACKAGE__;

  use strict;
  use warnings;

  sub deref : lvalue {
	substr($_[0]->value, $_[0]->{_index})
  }

  sub incr {
  	my $self = shift;
  	my $n    = shift || 1;

  	## check above *and* below in case a negative is used
  	$self->{_fatal} and Carp::croak("beyond boundary of scalar")
  		if $self->{_index} + $n > length $self->value;
	
  	$self->{_index} += $n;

  	return $self;
  }

  sub decr {
  	my $self = shift;
  	my $n    = shift;

  	Carp::croak("below boundary of scalar") if $self->{_index} - $n < 0;

  	$self->{_index} -= $n;

  	return $self;
  }

  sub plus {
  	my $self = shift;
  	my $n    = shift;

  	my $offset = $self->{_index} + $n;
  	$self->{_fatal} and Carp::croak("beyond boundary of scalar")
  		if $offset > length $self->value or $offset < 0;

  	return $self->mutant( index => $offset );
  }

  sub minus {
  	my $self = shift;
  	my $n    = shift;

  	my $offset = $self->{_index} - $n;
  	$self->{_fatal} and Carp::croak("beyond boundary of scalar")
  		if $offset < 0 or $offset > length $self->value;

  	return $self->mutant( index => $offset );
  }
}

{
  package Data::Pointer::SCALAR::Char;

  @ISA = qw(Data::Pointer::SCALAR::String);

  push @Data::Pointer::register, __PACKAGE__;

  use strict;
  use warnings;

  sub deref : lvalue {
	substr($_[0]->value, $_[0]->{_index}, 1)
  }
}

q(Data::Pointer::SCALAR good to go ...);
