################################################################################
#
# $Project: /Devel-Tokenizer-C $
# $Author: mhx $
# $Date: 2003/06/11 03:28:26 +0200 $
# $Revision: 2 $
# $Snapshot: /Devel-Tokenizer-C/0.03 $
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
  'NAME'         => 'Devel::Tokenizer::C',
  'VERSION_FROM' => 'C.pm',
  'ABSTRACT'     => 'Generate C source for fast keyword tokenizer',
  'AUTHOR'       => 'Marcus Holland-Moritz <mhx@cpan.org>',
);
