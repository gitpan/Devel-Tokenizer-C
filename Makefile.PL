################################################################################
#
# $Project: /Devel-Tokenizer-C $
# $Author: mhx $
# $Date: 2003/03/17 21:20:07 +0100 $
# $Revision: 1 $
# $Snapshot: /Devel-Tokenizer-C/0.01 $
# $Source: /Makefile.PL $
#
################################################################################
# 
# Copyright (c) 2002-2003 Marcus Holland-Moritz. All rights reserved.
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
# 
################################################################################

use 5.005_03;
use ExtUtils::MakeMaker;

WriteMakefile(
  'NAME'            => 'Devel::Tokenizer::C',
  'VERSION'         => do { my @r = '$Snapshot: /Devel-Tokenizer-C/0.01 $'
                                    =~ /(\d+\.\d+(?:_\d+)?)/;
                            @r ? $r[0] : '9.99' },
  'ABSTRACT'        => 'Generate C source for fast keyword tokenizer',
  'AUTHOR'          => 'Marcus Holland-Moritz <mhx@cpan.org>',
);
