################################################################################
#
# $Project: /Devel-Tokenizer-C $
# $Author: mhx $
# $Date: 2003/03/17 21:20:31 +0100 $
# $Revision: 1 $
# $Snapshot: /Devel-Tokenizer-C/0.03 $
# $Source: /t/103_build.t $
#
################################################################################
# 
# Copyright (c) 2002-2003 Marcus Holland-Moritz. All rights reserved.
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
# 
################################################################################

use Test;
use Devel::Tokenizer::C;
use strict;

do 't/common.sub';

$^W = 1;

BEGIN { plan tests => 24 }

chomp( my @words = <DATA> );

my $skip = can_compile() ? '' : 'skip: cannot run compiler';

run_tests( $skip, \@words, { ppflags => 0, case => 0 } );
run_tests( $skip, \@words, { ppflags => 1, case => 0 } );

run_tests( $skip, \@words, { ppflags => 0, case => 1 } );
run_tests( $skip, \@words, { ppflags => 1, case => 1 } );

sub run_tests {
  my($skip, $words, $options) = @_;
  my $unknown = @$words;
  my %words;
  @words{@$words} = (0 .. $#$words);

  my $t = new Devel::Tokenizer::C TokenFunc     => sub { "return KEY_$_[0];\n" }
                                , CaseSensitive => $options->{case}
                                , TokenEnd      => 'TOKEN_END'
                                ;

  my($c, %dir) = 0;
  for( @$words ) {
    unless( $c ) {
      $c = int( 1 + rand( length ) );
      $dir{uc $_}++;
      $t->add_tokens( [$_], "defined HAVE_\U$_" );
    }
    else {
      $t->add_tokens( [$_] );
    }
  
    $c--;
  }

  my $src = gencode( $t, $words );

  my @ppflags;
  if( $options->{ppflags} ) {
    @ppflags = keys %dir;
    while( @ppflags > 5 ) {
      splice @ppflags, rand @ppflags, 1;
    }
    delete @dir{@ppflags};
    for( @ppflags ) { s/^/-DHAVE_/ }
  }

  my @test = @$words;

  print "# generating random words\n";
  while( @test < 1000 ) {
    my $key = rand_key();
    exists $words{$key} or push @test, $key;
  }

  my(@in, @ref);

  for my $k ( @test ) {
    my($up, $lo, $rev) = ($k)x3;
    $rev =~ tr/a-zA-Z/A-Za-z/;
    my @p = ($k, $up, $lo, $rev);
    push @in, @p;

    if( exists $words{$k} ) {
      if( exists $dir{uc $k} ) {
        push @ref, map [$_ => $unknown], @p;
      }
      else {
        push @ref, map [$_ => $_ eq $k || $options->{case} == 0 ? $words{$k} : $unknown], @p;
      }
    }
    else {
      push @ref, map [$_ => $unknown], @p;
    }
  }
  
  my($out) = runtest( $skip, $src, \@in, ccflags => \@ppflags );

  my $count = -1;
  my $fail  = -1;

  if( defined $out ) {
    $count = $fail = 0;
    for( @$out ) {
      my($key, $val) = /"(.*)"\s+=>\s+(\d+)/ or next;
      my $ref = shift @ref;
      if( $ref->[0] ne $key ) {
        print "# wrong keyword, expected $ref->[0], got $key\n";
        $fail++;
      }
      if( $ref->[1] ne $val ) {
        print "# wrong value, expected $ref->[1], got $val\n";
        $fail++;
      }
      $count++;
    }
  }

  skip( $skip, $fail, 0, "recognition failed" );
  skip( $skip, $count, 4000, "invalid number of words parsed" );
}

sub rand_key
{
  my $key = '';
  my @letters = ('a' .. 'z', 'A' .. 'Z', '0' .. '9', qw( _ . : ; . ' + * ? ! " § $ % [ ] & / < > = } { ));
  for( 0 .. rand(30) ) {
    $key .= $letters[rand @letters];
  }
  $key;
}

# following are random words from /usr/share/dict/words

__DATA__
Abrus
Aegithognathae
Aganice
Agaricus
Amentiferae
Amentifera
Argas
Ascanian
Asterolepis
Babeldom
Brahmoism
Buddh
Burhinidae
Dasypodidae
Dolichos
Doric
Dowieite
Esselen
Fouquieria
Gapa
Gloiosiphoniaceae
Hura
Iceland
Ichthyosaurus
Igdyr
Irelander
Janizary
Lanuvian
Lincolnian
Lithuanian
Marylandian
Monacanthidae
Monocondyla
Myxosporidiida
Nectrioidaceae
Nymphalinae
Palmyrene
Parthenolatry
Patricia
Pepysian
Petrea
Phaet
Punic
Reichsland
Rinde
Romane
Salva
Seleucidae
Serranus
Silicospongiae
Strongylosis
Tahiti
Tebu
Teutomaniac
Tigre
Tomkin
Trypaneidae
Urocerata
Ventriculites
Vermetidae
Winnipesaukee
Yukian
abbreviator
aberrance
acquisited
adenosine
adrenine
afterpeak
aga
albumoscope
alkool
allocute
alterably
amphistomous
anabibazon
anisate
antelegal
antic
antiserum
antorbital
appliableness
apsidal
archigastrula
ardent
armor
armpiece
arni
assume
astragalocentral
astrologize
atroscine
auricyanide
axmaking
balker
basifugal
beal
beaverish
becuffed
bedmate
bedspring
beeswax
bellwaver
bemuddy
benzoglycolic
beshackle
beshower
bicipital
bicostate
bidarka
biogenetical
blastocoele
blastodermic
blennogenic
blushfulness
boomorah
bott
bovate
brachiorrhachidian
broche
bufo
butcherdom
buxomness
cacocholia
cacotrophy
caitiff
cargoose
carmoisin
cathro
cephalodymus
cessionaire
changeably
cheating
cheeker
childless
chips
chocker
chough
circumspection
colloquiality
communicatory
complotter
concilium
conductible
consumpted
copatentee
coppering
coprophagy
corneule
corymbous
cosmical
coumaric
counterturned
crabweed
crosshand
cube
cycadofilicale
cyclocoelic
dactylous
dally
daviesite
dawdling
dedicatorily
deducibleness
degelatinize
derived
dermolysis
devouringness
dialytically
diapalma
dicyanodiamide
didymate
difficile
digitogenin
dirge
disconventicle
disputability
doctrinarianism
doctrinization
dotting
drachmae
drest
dun
durwaun
earringed
easiness
ecphoria
eelboat
electrodeless
electroengraving
electrometrically
encouragement
engolden
enter
envy
enwind
epigraphy
epilimnion
ergatoid
errite
ethical
euhemeristic
eutomous
exclamational
extracystic
extradition
fattable
faunology
ferme
ferratin
filemaker
flange
foundationless
fribblery
fulgurite
gaol
gastronosus
genual
geoponics
gimleteyed
glaciation
glimmerous
goatish
gooseflower
gratility
gryllos
haggle
hagiocracy
hagiography
halisteretic
handbarrow
harbor
hematogenic
hemitery
hepatoportal
hereunder
hieratically
historicus
honestness
hugeous
hyperbatically
ichthyism
immovable
inaccessibleness
incendiarism
inemotivity
integrally
interruptedly
intramundane
introthoracic
invectively
inveigle
inventorial
itchless
jawsmith
karyolytic
ketembilla
kikumon
ladylove
leath
leptocardian
liomyofibroma
lithopone
litterateur
lumpfish
mackenboy
macropterous
maggot
maholi
male
malease
masterer
medusiferous
meeken
megacoulomb
mensurably
meny
metope
metrocarat
metropolis
microlitic
micropaleontology
micropathology
microphotographic
micropyle
misbelievingly
missentence
mogulship
monopsonistic
muteness
mutualize
myopically
myringodermatitis
myristin
narratively
necromancer
neomedievalism
nephrogastric
netleaf
nodulate
nonattribution
noncondimental
nonconservative
nondetachable
nonperformance
nonswimming
nothous
nuditarian
ocelliferous
odontonecrosis
oleo
oleose
oligohydramnios
oliviform
ombrological
onchocercosis
onerary
oniomania
organismic
osseoalbuminoid
ossifluence
otoblennorrhea
ottajanite
ovatocylindraceous
overlively
oxyrhinous
pahutan
palmatilobate
pangful
papillosarcoma
paragram
parallelinervate
parochin
pastoral
phlogogenous
phoronomy
photesthesis
photoelectric
phylactic
physiognomically
physiurgic
physoclist
piddler
pietic
planetologist
pleomorphic
plurisporous
plutocracy
polycrystalline
porching
portionless
potboy
prakriti
praseodidymium
preimagination
preobjective
prescient
presider
procrastinating
profitmongering
progambling
proleptical
prosaically
prostatodynia
pulldevil
rabbinically
rabbinize
radiodigital
reaggregate
reaminess
reave
reckla
reem
regia
rejustify
relentless
remonetization
repartee
resinoid
retromingently
reverend
revisership
reviviscence
rhizotomi
rho
rhodanate
riempie
risk
roast
rober
roosters
roughslant
rubican
rummagy
rustre
sabadine
salfern
sandan
sandnatter
sandust
saprophyte
saturninely
sauld
scarlet
scourging
selvage
semideponent
senseful
septuagenarianism
shuler
sikhra
sinoatrial
slobber
slotter
socky
solio
soulish
southwards
spencerite
spherule
spindleful
splayfooted
splinty
sprug
squamosity
squidgy
stagewise
stalk
startfulness
stately
stepgrandson
stickily
sticktight
stiffleg
strounge
suaharo
subcolumnar
subphylar
suddle
sunburntness
surette
symbolizer
syndetic
synodite
tanglement
teatime
tectricial
teetotaler
temptability
terminist
thaumaturgy
torchon
toweringly
towniness
toxicologically
transpanamic
transpository
trichuriasis
tricky
trochitic
trustableness
tryingness
turfy
tylopodous
unadventurous
unbearably
unbenefiting
unbreakableness
uncrediting
undesire
undetached
unfussy
unherded
unjustled
unlegacied
unlight
unnaturalized
unpersuadably
unputtied
unquoted
unrevested
unstaidly
untractable
uranography
urediniospore
usury
vascularly
vermeology
virgate
virgulate
vocalizer
voltmeter
watertight
wealthiness
whits
wiring
woodeny
wride
xenomorphosis
xiphiid
zac
