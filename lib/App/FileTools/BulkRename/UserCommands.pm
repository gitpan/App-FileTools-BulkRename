package App::FileTools::BulkRename::UserCommands;
# ABSTRACT: User namespace routines.
use strict;
use warnings;

BEGIN
  { our
      $VERSION = substr '$$Version: 0.04 $$', 11, -3;
  }

use Clipboard;
use Contextual::Return;
use App::FileTools::BulkRename::Common qw(modifiable);
use App::FileTools::BulkRename::UserCommands::AutoFormat qw(afmt);

# We're overriding the core uc and lc routines to provide versions
# that automatically modify their parameters if called in void
# context.

# In practice this shouldn't be an issue, as uc and lc throw errors in
# void context, which is the only context in which these two subs are
# supposed to differ, but better safe than sorry.

package _USER;
use subs qw(uc lc);  # override the core routines.
package App::FileTools::BulkRename::UserCommands;

sub _USER::uc{ return afmt('upper',     @_); }
sub _USER::lc{ return afmt('lower',     @_); }

sub _USER::sc{ return afmt('sentence',  @_); }
sub _USER::tc{ return afmt('title',     @_); }
sub _USER::hc{ return afmt('highlight', @_); }

#
# These should be converted so they can take either scalars or lists
# and do the right thing...
#

sub _USER::spc
  { my $str  = $_[0] // $_;
    my $chrs = $_[1] // '._';
    my $pat=qr([\Q$chrs\E]);

    $str		     =~ s/$pat/ /g;
    if( VOID )
      { modifiable($_[0],$_) =	$str; return; }
    else
      { return $str; }
  }

sub _USER::slurp
  { my $fil = $_[0] // $_;

    if( VOID )
      { return modifiable($_[0], $_) = read_file($fil); }
    if( SCALAR )
      { return read_file($fil); }
    if( LIST )
      { my @ret = read_file($fil);

	chomp foreach @ret;
	return @ret;
      }
  }

sub _USER::clip
  { my $out = Clipboard::paste();

    if( VOID )
      { $_ = $out }
    if( SCALAR )
      { return $out }
    if( LIST )
      { return split("\n",$out); }
  }


# sub clip
#   { my $pat  = shift;
#     my $clip = Clipboard::paste();

#     if( SCALAR )
#       {
# 	return $clip unless defined $pat;
# 	my @list = ($clip =~ m($pat)mg);
# 	return join '',@list;
#       }

#     if( LIST )

# 	if( defined $pat )
#       {
# 	my @list = ($out =~ m($pat)mg);
# 	my $cap	 = $#+;

# 	print Dumper(\$pat,\$out,\@list,\$cap);
# 	exit -1;
#       }

#     # SCALARREF and ARRAYREF are autogenerated, so we don't
#     # bother defining them.
#     return
#       (
# 	::SCALAR  { $out		}
# 	::LIST    { split("\n",$out)	}
# 	::HASHREF { {}			}
#       );
#   }

sub _USER::rd
  { my @dirs = @_;

    push @dirs,$_ if !@dirs;

    my @ret;
    for my $dir (@dirs)
      { push @ret, sort(read_dir($dir)); }

    if( VOID )
      { return modifiable($_[0], $_) = join("\n",@ret)."\n"; }
    if( SCALAR )
      { return join("\n",@ret)."\n"; }
    if( LIST )
      { return @ret; }
  }

1;
