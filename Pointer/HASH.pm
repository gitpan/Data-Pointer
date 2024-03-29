{
  package Data::Pointer::HASH;
  $VERSION  = 0.5;
  @ISA    = qw(Data::Pointer);
  
  use strict;
  use warnings;
  
  use Want;
  use Tie::IxHash;

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
    
    my $hash = defined $opts->{_value} ? $opts->{_value} : {};
    tie(%{ $opts->{_value} }, 'Tie::IxHash', %$hash);
    
    bless $opts, $class;
  }

  ## util functions which are going to make this class **very** slow
  sub _keys    { keys %{$_[0]->value}         }
  sub _values  { values %{$_[0]->value}       }
  sub _size    { scalar $_[0]->_keys          }
  sub _index   { ($_[0]->_keys)[$_[1] || $_[0]->{_index} ] }
  
  sub assign {
    my $val = (@_ == 2 and ref($_[1]) eq 'HASH') ? pop : { @_[1 .. $#_] };
    
    $_[0] = $_[0]->mutant(
      value  => $val,
      'index'  => 0
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
  

    ## see. http://www.perlmonks.org/index.pl?node_id=185515
    my $ref = \$self->value->{$self->_index};
    want(qw/LVALUE ASSIGN LIST/) ?
      @{ $self->value }{ ( $self->_keys )[ $self->{_index} .. $self->_size - 1 ] }
    : want('LIST') ?
      %{ $self->value }
    :
      ${ $ref }
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
  
  sub plus  {
    my $self = shift;
    my $n    = shift;
    
    my $offset = $self->{_index} + $n;
    $self->{_fatal} and Carp::croak('outside boundary of pointer')
      if $offset > $self->_size - 1 or $offset < 0;
        
    return $self->mutant( index => $offset );
  }
  
  sub minus  {
    my $self = shift;
    my $n    = shift;
    
    my $offset = $self->{_index} - $n;
    $self->{_fatal} and Carp::croak('outside boundary of pointer')
      if $offset > $self->_size - 1 or $offset < 0;
        
    return $self->mutant( index => $offset );
  }
}

q(Data::Pointer::HASH good to go ...);

__END__

=head1 NAME

Data::Pointer::HASH - The HASH pointer type

=head1 SYNOPSIS

    use Data::Pointer qw(ptr);
  
    my $var = { qw( a list of words ) };
    my $ptr = ptr( $var );

    print $ptr->plus(1)->deref;           # listofwords
    print scalar $ptr->plus(1)->deref;    # list

    $ptr->deref = "foo";                  # $var->[0] eq 'foo'

=head1 DESCRIPTION

The HASH pointer type exists more for completeness than utility. The pointer
will be initialised to the first element from a C<keys> call on the hash that
it points to. Since it uses C<Tie::IxHash> for accessing the hash the order
should stay the same if new elements are added via a C<$p-E<gt>deref> assignment

=head2 METHODS

=over 4

=item assign($hash_ref)

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

=head1 THANKS

Gurusamy Sarathy for the oh so nice C<Tie::IxHash>

=head1 AUTHOR

Dan Brook C<E<lt>broquaint@hotmail.comE<gt>>

=head1 COPYRIGHT

Copyright (c) 2002, Dan Brook. All Rights Reserved. This module is free
software. It may be used, redistributed and/or modified under the same terms
as Perl itself.

=cut
