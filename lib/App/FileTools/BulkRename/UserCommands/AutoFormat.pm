package App::FileTools::BulkRename::UserCommands::AutoFormat;
# ABSTRACT: English title rewriting routines.
use strict;
use warnings;

BEGIN
  {
    $App::FileTools::BulkRename::UserCommands::AutoFormat::VERSION
      = substr '$$Version: 0.03 $$', 11, -3;
  }

require Exporter;

our @ISA = qw(Exporter);
our @EXPORT_OK=qw(afmt);

use Carp;
use Contextual::Return;
use Text::Autoformat;

use App::FileTools::BulkRename::Common qw(modifiable);

#
# Stuff Stolen from Text::Autoformat
#

# All of this is here so we can handle a greater variety of title
# formats than autoformat allows. Currently it only does 1,2,3 and 9.
#
# 1) Uppercase:
#    "THE VITAMINS ARE IN MY FRESH CALIFORNIA RAISINS"
# 2) Start-Case: Capitalize all words
#    "The Vitamins Are In My Fresh California Raisins"
# 3) Title-Case 1: Capitalize all but internal articles, prepositions,
#    and conjunctions:
#    "The Vitamins Are in My Fresh California Raisins"
# 4) Title-Case 2: Capitalize all but internal articles, prepositions,
#    conjunctions and forms of 'to be':
#    "The Vitamins are in My Fresh California Raisins"
# 5) Title-Case 3: Capitalize all but internal closed-class function words
#    (these are the word classes that are strongly conserved in a language,
#    and to which it is hard to add new members):
#    "The Vitamins are in my Fresh California Raisins"
# 6) Noun-Case: Just capitalize nouns
#    "The Vitamins are in my fresh California Raisins"
# 7) Sentence case: Just the first word and proper nouns (and a few
#    other exceptions for English Prose):
#    "The vitamins are in my fresh California raisins"
# 8) Proper-Noun Case: Only proper nouns are capitalized.
#    "the vitamins are in my fresh California raisins"
# 9) Lowercase
#    "the vitamins are in my fresh california raisins"



my %ignore =
  map {$_ => 1}
    qw
      { a an at as and are
	but by
	ere
	for from
	in into is
	of on onto or over
	per
	the to that than
	until unto upon
	via
	with while whilst within without
      };


my @entities =
  qw
    {
      &Aacute;   &aacute;      &Acirc;    &acirc;        &AElig;    &aelig;
      &Agrave;   &agrave;      &Alpha;    &alpha;        &Atilde;   &atilde;
      &Auml;     &auml;        &Beta;     &beta;         &Ccedil;   &ccedil;
      &Chi;      &chi;         &Delta;    &delta;        &Eacute;   &eacute;
      &Ecirc;    &ecirc;       &Egrave;   &egrave;       &Epsilon;  &epsilon;
      &Eta;      &eta;         &ETH;      &eth;          &Euml;     &euml;
      &Gamma;    &gamma;       &Iacute;   &iacute;       &Icirc;    &icirc;
      &Igrave;   &igrave;      &Iota;     &iota;         &Iuml;     &iuml;
      &Kappa;    &kappa;       &Lambda;   &lambda;       &Mu;       &mu;
      &Ntilde;   &ntilde;      &Nu;       &nu;           &Oacute;   &oacute;
      &Ocirc;    &ocirc;       &OElig;    &oelig;        &Ograve;   &ograve;
      &Omega;    &omega;       &Omicron;  &omicron;      &Otilde;   &otilde;
      &Ouml;     &ouml;        &Phi;      &phi;          &Pi;       &pi;
      &Prime;    &prime;       &Psi;      &psi;          &Rho;      &rho;
      &Scaron;   &scaron;      &Sigma;    &sigma;        &Tau;      &tau;
      &Theta;    &theta;       &THORN;    &thorn;        &Uacute;   &uacute;
      &Ucirc;    &ucirc;       &Ugrave;   &ugrave;       &Upsilon;  &upsilon;
      &Uuml;     &uuml;        &Xi;       &xi;           &Yacute;   &yacute;
      &Yuml;     &yuml;        &Zeta;     &zeta;
  };

my %lower_entities = @entities;
my %upper_entities = reverse @entities;

my %casing =
  ( lower =>
      [ \%lower_entities,  \%lower_entities
      , sub { $_ =  lc },   sub { $_ = lc }
      ]
  , upper =>
      [ \%upper_entities,  \%upper_entities
      , sub { $_ =  uc },   sub { $_ = uc }
      ]
  , title =>
      [ \%upper_entities,  \%lower_entities
      , sub { $_ =  ucfirst lc }, sub { $_ = lc }
      ]
  );

sub recase
  { my ($origtext, $case) = @_;
    my ($entities, $other_entities, $first, $rest) = @{$casing{$case}};

    my $text   = "";
    my @pieces = split /(&[a-z]+;)/i, $origtext;
    use Data::Dumper 'Dumper';
    push @pieces, "" if @pieces % 2;
    return $text unless @pieces;
    local $_   = shift @pieces;
    if (length $_)
      {
	$entities = $other_entities;
	&$first;
	$text .= $_;
      }
    return $text unless @pieces;
    $_	   = shift @pieces;
    $text .= $entities->{$_} || $_;
    while (@pieces)
      {
	$_ = shift @pieces; &$rest; $text .= $_;
	$_ = shift @pieces; $text .= $other_entities->{$_} || $_;
      }
    return $text;
  }

my $alword = qr{(?:\pL|&[a-z]+;)(?:[\pL']|&[a-z]+;)*}i;

# entitle is used like this:
#
# if ($args{case} =~ /upper/i) {
#     $para->{text} = recase($para->{text}, 'upper');
# }
# if ($args{case} =~ /lower/i) {
#     $para->{text} = recase($para->{text}, 'lower');
# }
# if ($args{case} =~ /title/i) {
#     entitle($para->{text},0);
# }
# if ($args{case} =~ /highlight/i) {
#     entitle($para->{text},1);
# }

sub entitle
  { my $ignore = pop;
    local *_ = \shift;

    # put into lowercase if on stop list, else titlecase
    s{($alword)}
     { $ignore && $ignore{lc $1} ? recase($1,'lower') : recase($1,'title') }gex;

    s/^($alword) /recase($1,'title')/ex;  # last word always to cap
    s/ ($alword)$/recase($1,'title')/ex;  # first word always to cap

    # treat parethesized portion as a complete title
    s/\( ($alword) /'('.recase($1,'title')/ex;
    s/($alword) \) /recase($1,'title').')'/ex;

    # capitalize first word following colon or semi-colon
    s/ ( [:;] \s+ ) ($alword) /$1 . recase($2,'title')/ex;
  }

#
# End of Text::Autoformat Stuff.
#

# autoformat shim. Takes a case conversion name, and optionally
# something to convert. If not passed anything to convert, it will
# work on $_. If called in void context, it will modify its input
# (including $_, when appropriate).

sub afmt
  { my $case = shift;
    my $opt  = { case => $case };
    my @ret;

    foreach my $in (@_)
      {
#	confess("Afmt:$in:$opt\n");
	my $out = autoformat($in, $opt);

	# needed because autoformat returns undef for a blank input.
	$out = '' unless defined $out;

	chomp($out); chomp($out);
	if( VOID )
	  { modifiable($in,$_) = $out; }
	else
	  { push @ret, $out }
      }

    if( SCALAR )
      { return $ret[0]; }
    else
      { return @ret; }
  }

1;
