{
  package Data::Pointer::IO;
  $VERSION    = 0.5;
  @ISA        = qw(Data::Pointer);

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

    $opts->{_subtype} = exists $opts->{_subtype} ? $opts->{_subtype} : 'Line';

    my(@args) = $opts->{_value};
    push @args, rec_sep => \1
        if Data::Pointer::i_eq($opts->{_subtype}, 'Char');
    
    $opts->{_value} = [];
    tie(@{ $opts->{_value} }, 'Tie::File', @args)
        or Carp::croak("Couldn't tie file: $!");

    bless $opts, $class . '::' . ucfirst lc $opts->{_subtype};
  }

  sub DESTROY {
    untie @{ $_[0]->value };
  }
}

{
  package Data::Pointer::IO::Line;
  $VERSION    = 0.1;
  @ISA        = qw(Data::Pointer::IO);

  use strict;
  use warnings;

  use Tie::File;
  use Want;
 
  sub assign {
    my $val = [];
    if(@_ == 2 and Data::Pointer::_find_type($_[1]) eq 'IO' and *{$_[1]}{IO}) {
        tie(@$val, 'Tie::File', pop)
            or Carp::croak("Couldn't tie file: $!");
    } else {
        Carp::croak("Unknown IO type $_[1]");
    }
      
    $_[0] = $_[0]->mutant(
        value    => $val,
        'index'    => 0,
    );
  }

  sub value : lvalue { $_[0]->{_value} }

  sub deref : lvalue {
    my $self = shift;

      my $ref = \$self->value->[$self->{_index}];
      want('LIST') ?
          @{ $self->value }
    :
          ${ $ref }
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

  sub plus    {
      my $self = shift;
      my $n    = shift;
      
      return $self->mutant( index =>  $self->{_index} + $n);
  }

  sub minus    {
      my $self = shift;
      my $n    = shift;
      
      return $self->mutant( index =>  $self->{_index} - $n);
  }
}

{
  package Data::Pointer::IO::Char;
  $VERSION    = 0.1;
  @ISA        = qw(Data::Pointer::IO::Line);

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
        value    => $val,
        'index'    => 0,
    );
  }
}

q(Data::Pointer::IO good to go ...);

__END__

=head1 NAME

Data::Pointer::IO - The IO pointer type

=head1 SYNOPSIS

    use Data::Pointer qw(ptr);
  
    open(my $fh, '<', 'somefile.txt') or die("ack - $!");
    my $ptr = ptr( $fh );

    print scalar $ptr->deref;                # first line of file
    print $ptr->deref;                    # all of file
  
    open(my $fh, '>', 'somefile.txt') or die("ack - $!");
    my $ptr = ptr( $fh );

    $ptr->deref = "foo";                  # first line of somefile.txt
                                          # now equals 'foo'

=head1 DESCRIPTION

The IO pointer type works on a per line basis (or whatever $/ is set to).
Because most of the magic is done by Tie::File it the dereferencing and
assignment should work in a similar way.

=head2 METHODS

=over 4

=item assign($filehandle)

Assign the pointer to a different value
    
    p = fopen('somefile', 'r')

=item deref

Dereference the pointer or assign to the value it's pointing to
    
    fgets(ret, SIZE_OF_$/, p)
    fputs(val, p)

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

Dominus for the all singing, all dancing C<Tie::File>

=head1 AUTHOR

Dan Brook C<E<lt>broquaint@hotmail.comE<gt>>

=head1 COPYRIGHT

Copyright (c) 2002, Dan Brook. All Rights Reserved. This module is free
software. It may be used, redistributed and/or modified under the same terms
as Perl itself.

=cut
