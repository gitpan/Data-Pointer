{
  package Data::Pointer;

  require Exporter;

  $VERSION    = 0.51;
  @ISA      = qw( Exporter );
  @EXPORT_OK  = qw( ptr char_ptr );

  use vars qw( @register @core_types );

  @core_types = qw/SCALAR ARRAY HASH GLOB IO::File/;

  use strict;
  use warnings;

  use Carp;
  use Data::Dumper;

  {
    my @options = qw(value type subtype size fatal);
    sub new {
      my $class  = shift;
      my %opts  = @_;

      Carp::croak('how dare you call *me* as a function!')
        if not defined $class;

      my %self = map  { '_'.$_ => $opts{$_} }
                 grep { exists $opts{$_} } @options;

      $self{_index} = 0;
      $self{_fatal} = defined $self{_fatal} && $self{_fatal};

	  $self{_type} = _find_type($self{_value}) unless exists $self{_type};
      my $obj = "Data::Pointer::$self{_type}";

      ## don't let the module know what it's using ...
      eval qq{ use $obj; };
      Carp::croak("failure including $obj - $@") if $@;

      return $obj->new(%self);
    }
  }

  sub i_eq {
    my $self = UNIVERSAL::isa($_[0], __PACKAGE__) ? shift : undef;

    my $first = shift;
	my $rest  = '(?:'. join('|', @_) .')';

	return $first =~ m< ^ $rest \z >xi;
  }
  
  sub _find_type {
    my $val = shift;

    my $core_types = '^(?:' . join('|', @core_types) . ')$';

    return(i_eq(ref $val, 'GLOB', 'IO::File') ? 'IO' : ref $val)
      if ref($val) =~ /$core_types/;

    my $r = ref \$val;
    return(i_eq(ref $val, 'GLOB', 'IO::File') ? 'IO' : $r)
		if $r =~ /$core_types/;

    if(ref $val eq 'REF' or $r eq 'REF') {
      Carp::croak("not enough information from REF value");
    } else {
      Carp::croak("unrecognised type '$r'");
    }
  }

  sub mutant {
    my $obj  = shift;
    my %opts = @_;

    my %clone;
    @clone{keys %$obj} = values %$obj;

    $clone{'_'.$_} = $opts{$_} for keys %opts;

    return bless \%clone, ref $obj;
  }

  sub ptr {
    my $self = UNIVERSAL::isa($_[0], __PACKAGE__) ? shift : undef;
    
    my(%opts, $val);
    no warnings 'void';
    my $got_odd_args = @_ > 1 and (@_ % 2) == 1;
    
    if(@_ == 1 or $got_odd_args) {
      Carp::cluck('value defined twice or odd number of args for ptr')
        if $got_odd_args and defined {@_[1 .. $#_]}->{value};
      $val = shift @_;
    }
    
    %opts = @_;
    $opts{value} = $val;
    return __PACKAGE__->new( %opts );
  }

  sub char_ptr { return ptr(@_, subtype => 'CHAR') }

  sub value : lvalue {
    my $self = shift;
    $self->{_value};
  }

  ## filler methods
  #sub assign { $_[0]->{_value} = $_[1]      }
  sub assign  { Carp::croak("${\scalar caller} hasn't implemented assign()")}
  #sub deref  { $_[0]->{_value}      }
  sub deref   { Carp::croak("${\scalar caller} hasn't implemented deref()")}
  #sub incr   { $_[0]->{_index} += $_[1]  }
  sub incr    { Carp::croak("${\scalar caller} hasn't implemented incr()")}
  #sub decr   { $_[0]->{_index} -= $_[1]  }
  sub decr    { Carp::croak("${\scalar caller} hasn't implemented decr()")}
  #sub plus   { $_[0]->{_index} + $_[1]  }
  sub plus    { Carp::croak("${\scalar caller} hasn't implemented plus()")}
  #sub minus  { $_[0]->{_index} - $_[1]  }
  sub minus   { Carp::croak("${\scalar caller} hasn't implemented minus()")}

  sub DESTROY { }
}

q(Data::Pointer good to go ...);

__END__

=head1 NAME

Data::Pointer - Implementation of the concept of C pointers for perl data types

=head1 SYNOPSIS

	use Data::Pointer qw(ptr);
  
	my $var = [ qw( a list of words ) ];
	my $ptr = ptr( $var );

	print $ptr->plus(1)->deref;           # listofwords
	print scalar $ptr->plus(1)->deref;    # list

	$ptr->deref = "foo";                  # $var->[0] eq 'foo'

=head1 DESCRIPTION

Have you ever used pointers in C? Well then using this module should be pretty
straight-forward. It implements the basic set of pointer operations which I
thought to be useful. Currently 4 of the basic perl data types are implemented
(which are SCALAR, ARRAY, HASH and IO[1]) and should behave in an intuitive
manner which is also documented in their respective docs.

[1] IO is really a GLOB at this point, although eventually I'd like to
implement GLOB pointers if it's at all feasible
 
=head2 METHODS

=over 4

=item new(%options)

The class constructor method (see. C<mutant> for the object constructor method)
It takes arguments in the form of key value pairs and takes the following
parameters

	value   => What the pointer will be pointing, doesn't have to be a reference
	type    => The type of pointer e.g SCALAR
	subtype => The subtype of the type of pointer e.g CHAR
	size    => Amount of memory to allocate (NOTE: not currently used)
	fatal   => If set, the program will die if a pointer goes out of bounds

=item mutant(%options)

Will mutate the object according to the given parameters

=back

=head2 EXPORT_OK

=over 4

=item ptr($val[, %options])

A wrapper around new(). Just provide it with a value and it'll return the
correct pointer object.

=item char_ptr($string[, %options])

Creates a character pointer

=back

=head1 AUTHOR

Dan Brook C<E<lt>broquaint@hotmail.comE<gt>>

=head1 SEE ALSO

K&R, Tie::File

=cut
