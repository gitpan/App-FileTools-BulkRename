#/usr/bin/perl -w

use Test::More;

use_ok(App::FileTools::BulkRename::UserCommands::AutoFormat, qw(afmt));

sub check_afmt
  { my ($case,$name,$in,$out) = @_;

    $_ = $in;
    afmt($case);
    is( $_, $out, "afmt($case,$name), void context, implicit arg");

    $_ = $in;
    afmt($case,$_);
    is( $_, $out, "afmt($case,$name), void context, explicit arg");

    $_ = $in;
    my $t = afmt($case);
    is( $t, $out, "afmt($case,$name), scalar context, implicit arg");
    
    $t = afmt($case,$in);
    is( $t, $out, "afmt($case,$name), scalar context, explicit arg");
    
    $_ = $in;
    my @t = afmt($case);
    is( $t[0],$out , "afmt($case,$name), list context, implicit arg");
    
    @t = afmt($case,$in);
    is( $t[0],$out , "afmt($case,$name), list context, explicit arg");
  };

check_afmt('any', "undef", undef, undef);
check_afmt('any', "empty", '',    '');

check_afmt('upper',     "simple", "X is WHY", "X IS WHY");
check_afmt('lower',     "simple", "X is WHY", "x is why");
check_afmt('sentence',  "simple", "X is WHY", "X is why");
check_afmt('title',     "simple", "X is WHY", "X Is Why");
check_afmt('highlight', "simple", "X is WHY", "X is Why");

TODO:
  { local $TODO = "autoformat gets these wrong.";

    check_afmt
      ( 'sentence',  "divided"
      , "X is WHY - WHY is X", "X is why - Why is x"
      );
    check_afmt
      ( 'title',     "divided"
      , "X is WHY - WHY is X", "X Is Why - Why Is X"
      );
    check_afmt
      ( 'highlight',     "divided"
      , "X is WHY - WHY is X", "X is Why - Why is X"
      );
  }

done_testing();

