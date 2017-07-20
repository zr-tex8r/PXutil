use strict;
use File::Basename 'dirname';

chdir(dirname($0));
my $work_root_dir = "../../..";
my $pxutil_file = "$work_root_dir/PXutil/pxutil.pl";
my $ZRTeXtor_file = "$work_root_dir/ZRTeXtor/ZRTeXtor.pm";
my $output_file = "../jfmutil.pl";

my ($pxutil, $ZRTeXtor, $ZRTeXtor_version);
{
  local ($_, $/);
  open(my $hi, '<', $pxutil_file) or die "No file '$pxutil_file'";
  $pxutil = <$hi>; close($hi);
  open(my $hi, '<', $ZRTeXtor_file) or die "No file '$ZRTeXtor_file'";
  $ZRTeXtor = <$hi>; close($hi);
}
{
  local ($_); my (@ln, @ln_v); my $in = 0;
  foreach (split(m/\n/, $ZRTeXtor)) {
    if (m/^########/) {
      if (m/general/)         { $in = 1; }
      if (m/'x' section/)     { $in = 1; }
      if (m/'pl' section/)    { $in = 1; }
      if (m/'jcode' section/) { $in = 1; }
      if (m/'ps' section/)    { $in = 0; }
      if (m/'enc' section/)   { $in = 0; }
      if (m/'kpse' section/)  { $in = 1; }
      if (m/'ttf' section/)   { $in = 0; }
      if (m/'tfm' section/)   { $in = 0; }
      if (m/'vf' section/)    { $in = 1; }
      if (m/'jfm' section/)   { $in = 1; }
      if (m/'config' section/) { $in = 0; }
      if (m/initialization/)  { $in = 0; }
      if (m/all done/)        { $in = 0; }
      if (m/NOW UNDER CONSIDERATION/) { $in = 0; }
    }
    if ($in) { push(@ln, $_); }
    if (m/^our \$(?:VERSION|mod_date)/) { push(@ln_v, $_); }
  }
  $ZRTeXtor = join("\n", @ln);
  $ZRTeXtor_version = join("\n", @ln_v);
}
{
  local ($_); my (@ln); my $in = 0;
  foreach (split(m/\n/, $pxutil)) {
    if (m/^\#.*go to main/) { $in = 0; }
    if ($in) { push(@ln, $_); }
    if (m/^use ZRTeXtor/) { $in = 1; }
  }
  $pxutil = join("\n", @ln);
}
{
  local ($/, $_);
  $_ = <DATA>;
  s/##ZRTeXtor##/$ZRTeXtor/;
  s/##ZRTeXtor_version##/$ZRTeXtor_version/;
  s/##pxutil##/$pxutil/;
  s/pxutil/jfmutil/g;
  open(my $ho, '>', $output_file) or die "Cannot open '$output_file'";
  binmode($ho); print $ho ($_);
  close($ho);
}

__DATA__
#!/usr/bin/env perl
#
# This is file 'jfmutil.pl'.
#
# Copyright (c) 2017 Takayuki YATO (aka. "ZR")
#   GitHub:   https://github.com/zr-tex8r
#   Twitter:  @zr_tex8r
#
# This software is distributed under the MIT License.
#
use strict;

#------------------------------------------------- ZRTeXtor module
package ZRTeXtor;
##ZRTeXtor_version##
use Encode qw(encode decode);

# Here follows excerpt from ZRTeXtor.pm
#================================================= BEGIN
##ZRTeXtor##
#================================================= END
($jcode_in, $jcode_ex) = (undef, undef);
get_temp_name_init();
if (defined $errmsg) { error("initialization failed"); }

#------------------------------------------------- dumb importer
package main;
{
  no strict;
  foreach (qw(
    textool_error textool_version
    read_whole_file write_whole_file
    pl_parse pl_form pl_prefer_hex
    jcode_set
    kpse
    vf_parse vf_form vf_parse_ex vf_form_ex
    jfm_use_uptex_tool jfm_parse jfm_form
  )) {
    *{$_} = *{"ZRTeXtor::".$_};
  }
}

#------------------------------------------------- pxutil stuffs
# Here follows excerpt from pxutil.pl
#================================================= BEGIN
##pxutil##
#================================================= END

#------------------------------------------------- go to main
main();
## EOF
