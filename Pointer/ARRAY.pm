{
  package Data::Pointer::ARRAY;
  $VERSION  = 0.5;
  @ISA    = qw(Data::Pointer);
  
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
  
  sub assign {
    my $val = (@_ == 2 and ref($_[1]) eq 'ARRAY') ? pop : [ @_[1 .. $#_] ];
    
    $_[0] = $_[0]->mutant(
      value  => $val,
      'index'  => 0,
    );
  }
  
  sub deref : lvalue {
    my $self = shift;
    
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
  
    my $scalar = scalar @{[ @{ $self->value }
               [ $self->{_index} .. @{$self->value} - 1 ] ]};
    want(qw/LVALUE ASSIGN LIST/) ?
      @{ $self->value }[ $self->{_index} .. @{$self->value} - 1 ]
    : want(qw/LVALUE ASSIGN SCALAR/) ?
      $self->value->[$self->{_index}]
    : want('LIST') ?
      @{ $self->value }[ $self->{_index} .. @{$self->value} - 1 ]
    : want('SCALAR') ?
      $self->value->[$self->{_index}]
    :
      $self->value->[$self->{_index}]
  }
  
  sub incr {
    my $self = shift;
    my $n    = shift || 1;
  
    my $offset = $self->{_index} + $n;
    $self->{_fatal} and Carp::croak("beyond boundary of scalar")
      if $offset > @{$self->value} - 1 or $offset < 0;
  
    $self->{_index} += $n;
  
    return $self;
  }
  
  sub decr {
    my $self = shift;
    my $n    = shift || 1;
  
    my $offset = $self->{_index} - $n;
    $self->{_fatal} and Carp::croak("beyond boundary of scalar")
      if $offset > @{$self->value} - 1 or $offset < 0;
  
    $self->{_index} -= $n;
  
    return $self;
  }
  
  sub plus  {
    my $self = shift;
    my $n    = shift;
    
    my $offset = $self->{_index} + $n;
    $self->{_fatal} and Carp::croak('beyond boundary of pointer')
      if $offset > @{$self->value} - 1 or $offset < 0;
        
    return $self->mutant( index => $offset );
  }
  
  sub minus  {
    my $self = shift;
    my $n    = shift;
    
    my $offset = $self->{_index} - $n;
    $self->{_fatal} and Carp::croak('beyond boundary of pointer')
      if $offset > @{$self->value} - 1 or $offset < 0;
        
    return $self->mutant( index => $offset );
  }
}

q(Data::Pointer::ARRAY good to go ...);

__END__

=head1 NAME

Data::Pointer::ARRAY - The cARRAY pointer type

=head1 SYNOPSIS

	use Data::Pointer qw(ptr);
  
	my $var = [ qw( a list of words ) ];
	my $ptr = ptr( $var );

	print $ptr->plus(1)->deref;           # listofwords
	print scalar $ptr->plus(1)->deref;    # list

	$ptr->deref = "foo";                  # $var->[0] eq 'foo'

=head1 DESCRIPTION

The ARRAY pointer type behaves in a very simliar way to 'arrays' in C. The
pointer points to inidividual elements of the array and can be incremented
and dereferenced as one would expect.

=head2 METHODS

=over 4

=item assign($array_ref)

Assign the pointer to a different value
	
	p = val

=item deref

Dereference the pointer or assign to the value it's pointing to
	
	*p
	*p = val

=item incr([$num])

Increments the position of the pointer (default is 1)
	
	p++

=item decr([$num])

Decrements the position of the pointer (default is 1)
	
	p--

=item plus($num)

Return a pointer by the given offset

	p + 1

=item minus($num)

Return a pointer by the given offset

	p - 1

=back

=head1 AUTHOR

Dan Brook C<E<lt>broquaint@hotmail.comE<gt>>

=cut
