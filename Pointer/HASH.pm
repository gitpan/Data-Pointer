{
  package Data::Pointer::HASH;
  $VERSION	= 0.3;
  @ISA		= qw(Data::Pointer);
  
  push @Data::Pointer::register, __PACKAGE__;
  
  use strict;
  use warnings;
  
  use Want;

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
  	bless $opts, $class;
  }
  
  ## util functions which are going to make this class **very** slow
  sub _keys		{ keys %{$_[0]->value}					}
  sub _values	{ values %{$_[0]->value}				}
  sub _size		{ scalar $_[0]->_keys					}
  sub _index	{ ($_[0]->_keys)[$_[1] || $_[0]->{_index} ] }
  
  use Data::Dumper;
  sub assign {
  	my $val = (@_ == 2 and ref($_[1]) eq 'HASH') ? pop : { @_[1 .. $#_] };
  	
  	$_[0] = $_[0]->mutant(
  		value	=> $val,
  		'index'	=> 0
  	);
  }
  
  sub deref : lvalue {
  	my $self = shift;
  
  	my @slice = @_ > 0 ?
  		@_
  	:
  		($self->_keys)[$self->{_index} .. $self->_size - 1];
  
  	if(defined $::DEBUGGING and $::DEBUGGING) {
  	want(qw/LVALUE ASSIGN LIST/) ?
  		print "wanted a LVALUE ASSIGN LIST\n"
  	: want(qw/LVALUE ASSIGN SCALAR/) ?
  		print "wanted a LVALUE ASSIGN SCALAR\n"
  	: want('LIST') ?
  		print "wanted a LIST\n"
  	: want('SCALAR') ?
  		print "wanted SCALAR\n"
  	:
  		print "wanted other\n";
  	}
  
  	## can we say 'hackish' ?
  	my $scalar = scalar @slice;
  	want(qw/LVALUE ASSIGN LIST/) ?
  		@{ $self->value }{ @slice }
  	: want(qw/LVALUE ASSIGN SCALAR/) ?
  		$self->value->{@_ == 1 ? shift : $self->_index}
  	: want('LIST') ?
  		%{ $self->value }
  	: want('SCALAR') ?
  		$scalar
  	:
  		$self->value->{@_ == 1 ? shift : $self->{_index}};
  }
  
  sub incr {
  	my $self = shift;
  	my $n    = shift;
  
  	my $offset = $self->{_index} + $n;
  	$self->{_fatal} and Carp::croak("beyond boundary of scalar")
  		if $offset > $self->_size - 1 or $offset < 0;
  
  	$self->{_index} += $n;
  
  	return $self;
  }
  
  sub decr {
  	my $self = shift;
  	my $n    = shift;
  
  	my $offset = $self->{_index} - $n;
  	$self->{_fatal} and Carp::croak("beyond boundary of scalar")
  		if $offset > $self->_size - 1 or $offset < 0;
  
  	$self->{_index} -= $n;
  
  	return $self;
  }
  
  sub plus	{
  	my $self = shift;
  	my $n    = shift;
  	
  	my $offset = $self->{_index} + $n;
  	Carp::croak('outside boundary of pointer')
  		if $offset > $self->_size - 1 or $offset < 0;
  			
  	return $self->mutant( index => $offset );
  }
  
  sub minus	{
  	my $self = shift;
  	my $n    = shift;
  	
  	my $offset = $self->{_index} - $n;
  	Carp::croak('outside boundary of pointer')
  		if $offset > $self->_size - 1 or $offset < 0;
  			
  	return $self->mutant( index => $offset );
  }
}

q(Data::Pointer::HASH good to go ...);
