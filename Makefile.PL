################################################################################
#
# $Project: /Devel-Tokenizer-C $
# $Author: mhx $
# $Date: 2005/01/28 15:01:03 +0100 $
# $Revision: 4 $
# $Source: /Makefile.PL $
#
################################################################################
# 
# Copyright (c) 2002-2005 Marcus Holland-Moritz. All rights reserved.
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
# 
################################################################################

use 5.005_03;
use ExtUtils::MakeMaker;

WriteMakefile(
  'NAME'         => 'Devel::Tokenizer::C',
  'VERSION_FROM' => 'lib/Devel/Tokenizer/C.pm',
  ($] >= 5.005 ?
    (ABSTRACT_FROM  => 'lib/Devel/Tokenizer/C.pm',
     AUTHOR         => 'Marcus Holland-Moritz <mhx@cpan.org>') : ()
  ),
);
