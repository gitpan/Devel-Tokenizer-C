################################################################################
#
# $Project: /Devel-Tokenizer-C $
# $Author: mhx $
# $Date: 2005/01/28 15:01:03 +0100 $
# $Revision: 2 $
# $Source: /t/001_init.t $
#
################################################################################
# 
# Copyright (c) 2002-2005 Marcus Holland-Moritz. All rights reserved.
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
# 
################################################################################

use Test;

$^W = 1;

BEGIN { plan tests => 1 }

eval { require Devel::Tokenizer::C };
ok($@,'',"failed to require Devel::Tokenizer::C");

