{
  package Data::Pointer::IO;
  $VERSION	= 0.1;
  @ISA		= qw(Data::Pointer);

  push @Data::Pointer::register, __PACKAGE__;

  use strict;
  use warnings;

  sub new {
  	my $class = shift;
  	my %opts  = @_;

  	Carp::croak("oooh you've got a nerve calling me as a class method!!!")
  		if caller() ne 'Data::Pointer';

  	my $self = _init($class, \%opts);

  	return $self;
  }

  sub _init {
  	my($class,$opts) = @_;

	$opts->{_type} = exists $opts->{_type} ? $opts->{_type} : 'Line';

	my(@args) = $opts->{_value};
	push @args, rec_sep => \1 if $opts->{_type} =~ m< ^ Char \z >xi;
	
	$opts->{_value} = [];
	tie(@{ $opts->{_value} }, 'Tie::File', @args);
	
  	bless $opts, $class . '::' . ucfirst lc $opts->{_type};
  }
}

{
  package Data::Pointer::IO::Line;
  $VERSION	= 0.1;
  @ISA		= qw(Data::Pointer::IO);

  push @Data::Pointer::register, __PACKAGE__;

  use strict;
  use warnings;

  use Tie::File;
  use Want;
 
  sub assign {
  	my $val = [];
	if(@_ == 2 and Data::Pointer::_find_type($_[1]) eq 'IO' and *{$_[1]}{IO}) {
		tie(@$val, 'Tie::File', pop);
	} else {
		Carp::croak("Unknown IO type $_[1]");
	}
  	
  	$_[0] = $_[0]->mutant(
  		value	=> $val,
  		'index'	=> 0,
  	);
  }

  sub value : lvalue { $_[0]->{_value} }

  sub deref : lvalue {
	my $self = shift;

  	want('LIST') ?
  		@{ $self->value }
	:
  		$self->value->[$self->{_index}];
  }

  sub incr {
	my $self = shift;
	my $n    = shift || 1;

	$self->{_index} += $n;

	return $self;
  }

  sub decr {
	my $self = shift;
	my $n    = shift || 1;

	$self->{_index} -= $n;

	return $self;
  }

  sub plus	{
  	my $self = shift;
  	my $n    = shift;
  	
  	return $self->mutant( index =>  $self->{_index} + $n);
  }

  sub minus	{
  	my $self = shift;
  	my $n    = shift;
  	
  	return $self->mutant( index =>  $self->{_index} - $n);
  }

  sub DESTROY {
	untie @{ $_[0]->value };
  }
}

{
  package Data::Pointer::IO::Char;
  $VERSION	= 0.1;
  @ISA		= qw(Data::Pointer::IO::Line);

  push @Data::Pointer::register, __PACKAGE__;

  use strict;
  use warnings;

  use Tie::File;

  sub assign {
  	my $val = [];
	if(@_ == 2 and $_[0]->_find_type($_[1]) eq 'IO' and *{$_[1]}{IO}) {
		tie(@$val, 'Tie::File', pop, rec_sep => \1);
	} else {
		Carp::croak("Unknown IO type $_[1]");
	}
  	
  	$_[0] = $_[0]->mutant(
  		value	=> $val,
  		'index'	=> 0,
  	);
  }
}

q(Data::Pointer::IO good to go ...);
