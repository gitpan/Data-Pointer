{
  package Data::Pointer::SCALAR;
  $VERSION  = 0.5;
  @ISA    = qw(Data::Pointer);

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

    $opts->{_isnum}    = is_numeric( value($opts) );
    $opts->{_subtype}  = $opts->{_isnum} ? 'NUMBER' : 'STRING'
      unless exists $opts->{_subtype};

    return bless $opts, __PACKAGE__ . '::' . ucfirst lc $opts->{_subtype};
  }

  sub value : lvalue {
    ref $_[0]->{_value} ? ${$_[0]->{_value}} : $_[0]->{_value};
  }

  sub assign  {
    $_[0] = $_[0]->mutant(
      value  => $_[1],
      'index'  => 0,
    );
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

  sub incr  { Carp::croak("can't increment pointer to a number")              }
  sub decr  { Carp::croak("can't decrement pointer to a number")              }
  sub plus  { Carp::croak("number pointers cannot be accessed by an offset")  }
  sub minus { Carp::croak("number pointers cannot be accessed by an offset")  }
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

__END__

=head1 NAME

Data::Pointer::SCALAR - The SCALAR pointer type

=head1 SYNOPSIS

	use Data::Pointer qw(ptr);
  
	my $ptr = ptr( 'foo bar baz' );

	print $ptr->plus(4)->deref, $/;                # bar baz

	$ptr->incr(4)->deref = 'quux';
	print "yup", $/ if $ptr->deref eq 'foo quux';  # yup

=head1 DESCRIPTION

The SCALAR pointer type is implemented much like strings are in C. However the
default behaviour is to point to a C<string> and not an array of C<char>s.
You can get C string-like behaviour by C<EXPORT>ing C<char_ptr> or passing
C<TYPE =E<gt> 'Char'> to the constructer (be it C<new> or C<ptr>).
 
=head2 METHODS

=over 4

=item assign($scalar)

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
