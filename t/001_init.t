################################################################################
#
# $Project: /Devel-Tokenizer-C $
# $Author: mhx $
# $Date: 2003/03/17 21:20:31 +0100 $
# $Revision: 1 $
# $Snapshot: /Devel-Tokenizer-C/0.01 $
# $Source: /t/001_init.t $
#
################################################################################
# 
# Copyright (c) 2002-2003 Marcus Holland-Moritz. All rights reserved.
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
# 
################################################################################

use Test;

$^W = 1;

BEGIN { plan tests => 1 }

eval { require Devel::Tokenizer::C };
ok($@,'',"failed to require Devel::Tokenizer::C");

