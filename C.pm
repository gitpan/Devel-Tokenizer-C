################################################################################
#
# MODULE: Devel::Tokenizer::C
#
################################################################################
#
# DESCRIPTION: Generate C source for fast keyword tokenizer
#
################################################################################
#
# $Project: /Devel-Tokenizer-C $
# $Author: mhx $
# $Date: 2003/03/17 21:36:58 +0100 $
# $Revision: 2 $
# $Snapshot: /Devel-Tokenizer-C/0.01 $
# $Source: /C.pm $
#
################################################################################
# 
# Copyright (c) 2002-2003 Marcus Holland-Moritz. All rights reserved.
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
# 
################################################################################

package Devel::Tokenizer::C;

use 5.005_03;
use strict;
use Carp;
use vars '$VERSION';

$VERSION = sprintf '%.2f', 0.01*('$Revision: 2 $' =~ /(\d+)/)[0];

my %DEF = (
  CaseSensitive => 1,
  TokenString   => 'tokstr',
  UnknownLabel  => 'unknown',
  TokenEnd      => "'\\0'",
  TokenFunc     => sub { "return $_[0];\n" },
);

sub new
{
  my $class = shift;
  my %opt = @_;
  for( keys %opt ) { exists $DEF{$_} or croak "Invalid option '$_'" }
  if( exists $opt{TokenFunc} ) {
    ref $opt{TokenFunc} eq 'CODE'
        or croak "Option TokenFunc needs a code reference";
  }
  bless {
    %DEF, @_,
    __tcheck__ => {},
    __tokens__ => {},
  }, $class;
}

sub add_tokens
{
  my $self = shift;
  my($tokens, $pre) = ref $_[0] eq 'ARRAY' ? @_ : \@_;
  for( @$tokens ) {
    my $tok = $self->{CaseSensitive} ? $_ : lc;
    exists $self->{__tcheck__}{$tok}
        and carp $self->{__tcheck__}{$tok} eq ($pre || '')
                 ? "Multiple definition of token '$_'"
                 : "Redefinition of token '$_'";
    $self->{__tcheck__}{$tok} = $self->{__tokens__}{$_} = $pre || '';
  }
  $self;
}

sub generate
{
  $_[0]->__makeit__( 0, 0, $_[0]->{__tokens__} );
}

sub __makeit__
{
  my($self, $level, $pre_flag, $t, %tok) = @_;
  my $indent = '    'x$level;

  %$t or return '';

  if( keys(%$t) == 1 ) {
    my($token) = keys %$t;
    my($rvs,$code);

    if( $level > length $token ) {
      $rvs = sprintf "%-50s/* %-10s */\n", $indent.'{', $token;
      $code = $self->{TokenFunc}->($token);
      $code =~ s/^/$indent  /mg;
    }
    else {
      my $cmp = join '', map {
                  my $str = $self->{CaseSensitive} || !/^[a-zA-Z]$/
                          ? $self->{TokenString}."[$level] == '$_' &&\n$indent    "
                          : '(' . $self->{TokenString} . "[$level] == '\U$_\E' || "
                                . $self->{TokenString} . "[$level] == '\L$_\E') &&\n$indent    ";
                  $level++; $str;
                } substr($token, $level) =~ /(.)/g;
      $rvs = $indent . 'if( ' . $cmp .
             $self->{TokenString}."[$level] == $self->{TokenEnd} )\n".
             sprintf "%-50s/* %-10s */\n", $indent.'{', $token;

      $code = $self->{TokenFunc}->($token);
      $code =~ s/^/$indent  /mg;
    }

    return "$rvs$code$indent}\n\n$indent"
          ."goto $self->{UnknownLabel};\n";
  }

  for( keys %$t ) {
    my $c = substr $_, $level, 1;
    $tok{$c ? ($self->{CaseSensitive} ? "'$c'" : "'\U$c\E'") : $self->{TokenEnd}}{$_} = $t->{$_};
  }

  my $rvs = $indent."switch( $self->{TokenString}\[$level] )\n".$indent."{\n";
  my $nlflag = 0;

  for( sort keys %tok ) {
    my($clear_pre_flag, %seen) = 0;
    my @pre = grep !$seen{$_}++, values %{$tok{$_}};

    $nlflag and $rvs .= "\n";

    if( $pre_flag == 0 && @pre == 1 && $pre[0] ) {
      $rvs .= "#if $pre[0]\n";
      $pre_flag = $clear_pre_flag = 1;
    }

    $rvs .= $self->{CaseSensitive} || !/^'[a-zA-Z]'$/
          ? "$indent  case $_:\n"
          : "$indent  case \U$_\E:\n"
          . "$indent  case \L$_\E:\n";
    $rvs .= $self->__makeit__( $level+1, $pre_flag, $tok{$_} );

    if( $clear_pre_flag ) {
      $rvs .= "#endif /* $pre[0] */\n";
      $pre_flag = 0;
    }

    $nlflag = 1;
  }

  <<EOS
$rvs
$indent  default:
$indent    goto $self->{UnknownLabel};
$indent}
EOS
}

1;

__END__

=head1 NAME

Devel::Tokenizer::C - Generate C source for fast keyword tokenizer

=head1 SYNOPSIS

  use Devel::Tokenizer::C;
  
  $t = new Devel::Tokenizer::C TokenFunc => sub { "return \U$_[0];\n" };
  
  $t->add_tokens( qw( bar baz ) )->add_tokens( ['for'] );
  $t->add_tokens( [qw( foo )], 'defined DIRECTIVE' );
  
  print $t->generate;

=head1 DESCRIPTION

The Devel::Tokenizer::C module provides a small class for creating
the essential ANSI C source code for a fast keyword tokenizer.

The generated code is optimized for speed. On the ANSI-C
keyword set, it's 2-3 times faster than equivalent code
generated with the C<gprof> utility.

The above example would print the following C source code:

  switch( tokstr[0] )
  {
    case 'b':
      switch( tokstr[1] )
      {
        case 'a':
          switch( tokstr[2] )
          {
            case 'r':
              if( tokstr[3] == '\0' )
              {                                     /* bar        */
                return BAR;
              }
  
              goto unknown;
  
            case 'z':
              if( tokstr[3] == '\0' )
              {                                     /* baz        */
                return BAZ;
              }
  
              goto unknown;
  
            default:
              goto unknown;
          }
  
        default:
          goto unknown;
      }
  
    case 'f':
      switch( tokstr[1] )
      {
        case 'o':
          switch( tokstr[2] )
          {
  #if defined DIRECTIVE
            case 'o':
              if( tokstr[3] == '\0' )
              {                                     /* foo        */
                return FOO;
              }
  
              goto unknown;
  #endif /* defined DIRECTIVE */
  
            case 'r':
              if( tokstr[3] == '\0' )
              {                                     /* for        */
                return FOR;
              }
  
              goto unknown;
  
            default:
              goto unknown;
          }
  
        default:
          goto unknown;
      }
  
    default:
      goto unknown;
  }

So the generated code only includes the main switch statement for
the tokenizer. You can configure most of the generated code to fit
for your application.

=head1 CONFIGURATION

=head2 TokenFunc =E<gt> SUBROUTINE

A reference to the subroutine that returns the code for each token
match. The only parameter to the subroutine is the token string.

This is the default subroutine:

  TokenFunc => sub { "return $_[0];\n" }

=head2 TokenString =E<gt> STRING

Identifier of the C character array that contains the token string.
The default is C<tokstr>.

=head2 UnknownLabel =E<gt> STRING

Label that should be jumped to via C<goto> if there's no keyword
matching the token. The default is C<unknown>.

=head2 TokenEnd =E<gt> STRING

Character that defines the end of each token. The default is the
null character C<'\0'>.

=head2 CaseSensitive =E<gt> 0 | 1

Boolean defining whether the generated tokenizer should be case
sensitive or not. This will only affect the letters A-Z. The
default is 1, so the generated tokenizer is case sensitive.

=head1 ADDING TOKENS

You can add tokens using the C<add_tokens> method.

The method either takes a list of token strings or a reference
to an array of token strings which can optionally be followed
by a preprocessor directive string.

Calls to C<add_tokens> can be chained together, as the method
returns a reference to its object.

=head1 GENERATING THE CODE

The C<generate> method will return a string with the tokenizer
switch statement. If no tokens were added, it will return an
empty string.

=head1 AUTHOR

Marcus Holland-Moritz E<lt>mhx@cpan.orgE<gt>

=head1 BUGS

I hope none, since the code is pretty short.
Perhaps lack of functionality ;-)

=head1 COPYRIGHT

Copyright (c) 2003, Marcus Holland-Moritz. All rights reserved.
This module is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
