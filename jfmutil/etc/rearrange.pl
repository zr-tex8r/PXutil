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
  $pxutil =~ s/pxutil/jfmutil/g;
}
{
  local ($/, $_);
  $_ = <DATA>;
  s/##ZRTeXtor##/$ZRTeXtor/;
  s/##ZRTeXtor_version##/$ZRTeXtor_version/;
  s/##pxutil##/$pxutil/;
  open(my $ho, '>', $output_file) or die "Cannot open '$output_file'";
  binmode($ho); print $ho ($_);
  close($ho);
}

__DATA__
#!/usr/bin/env perl
#
# This is file 'jfmutil.pl'.
#
# Copyright (c) 2018 Takayuki YATO (aka. "ZR")
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
    vf_parse vf_form vf_parse_ex vf_form_ex vf_strict
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

#------------------------------------------------- pxcopyfont interfaces

*usage_message_org = \&usage_message;

*usage_message = sub {
  local $_ = usage_message_org();
  my ($part1, $part2) = (<<"EOT1", <<"EOT2");

* ZVP Conversion
EOT1

* VF Replication
Usage: $prog_name vfcopy [<options>] <in.vf> <out.zvf> <out_base.tfm>...
       $prog_name vfinfo [<options>] <in.vf>
Arguments:
  <in.vf>       input virtual font name
    N.B. Input TFM/VF files are searched by Kpathsea.
  <out.vf>      output virtual font name
  <out_base.tfm>  names of raw TFMs referred by the output virtual font;
                each entry replaces a font mapping in the input font in
                the given order, so the exactly same number of entries
                must be given as font mappings
Options:
  -z / --zero     change first fontmap id in vf to zero
EOT2
  s/(Usage:)/$part1$1/; s/$/$part2/;
  return $_;
};

%procs = (%procs,
  vfinfo  => \&main_vfinfo,
  vfcopy  => \&main_vfcopy,
);

sub main_vfinfo {
  PXCopyFont::read_option(1);
  PXCopyFont::info_vf();
}

sub main_vfcopy {
  PXCopyFont::read_option(0);
  PXCopyFont::copy_vf();
}

#------------------------------------------------- pxcopyfont stuffs
package PXCopyFont;

*info = *main::show_info;
*error = *main::error;

our ($src_main, $dst_main, @dst_base, $op_zero);

sub copy_vf {
  local $_ = main::read_whole_file(main::kpse("$src_main.vf"), 1) or error();
  my $vfc = parse_vf($_);
  my ($nb, $nb1) = (scalar(@{$vfc->[0]}), scalar(@dst_base));
  info("number of base TFMs in '$src_main'", $nb);
  if ($dst_base[-1] eq '...' && $nb1 <= $nb) {
    foreach ($nb1-1 .. $nb-1) { $dst_base[$_] = $vfc->[0][$_][1]; }
  } elsif ($nb != $nb1) {
    error("wrong number of base TFMs given", $nb1);
  }
  main::write_whole_file("$dst_main.vf", form_vf($vfc), 1) or error();
  main::write_whole_file("$dst_main.tfm",
      main::read_whole_file(main::kpse("$src_main.tfm"), 1), 1) or error();
  foreach my $k (0 .. $#dst_base) {
    my $sfn = $vfc->[0][$k][1]; my $dfn = $dst_base[$k];
    ($sfn ne $dfn) or next;
    main::write_whole_file("$dfn.tfm",
      main::read_whole_file(main::kpse("$sfn.tfm"), 1), 1) or error();
  }
}

sub parse_vf {
  my ($vf) = @_; my (@fs, @lst, $pos);
  @fs = unpack("CCC", $vf);
  ($fs[0] == 0xf7 && $fs[1] == 0xca) or return;
  $pos = $fs[2] + 11; my $hd = substr($vf, 0, $pos);
  while (1) {
    @fs = unpack("CC", substr($vf, $pos, 2));
    (243 <= $fs[0] && $fs[0] <= 246) or last;
    my $fid = ($fs[0] == 243) ? $fs[1] : 999;
    my $t = $fs[0] - 242 + 13;
    @fs = unpack("a${t}CC", substr($vf, $pos, 260));
    my $l = $fs[1] + $fs[2]; my $n = substr($vf, $pos + $t + 2, $l);
    $pos += $t + 2 + $l; push(@lst, [ $fs[0], $n, $fid ]);
    if ($n !~ m/^[\x21-\x7e]+$/) {
      $n =~ s/([^\x21-\x5b\x5d-\x7e])/sprintf("\\x%02x", ord($1))/g;
      error("bad tfm name recorded in VF", $n);
    }
  }
  my $ft = substr($vf, $pos); $ft =~ s/\xf8+\z//g;
  return [ \@lst, $hd, $ft ];
}

sub info_vf {
  local $_ = main::read_whole_file(main::kpse("$src_main.vf"), 1) or error();
  my $vfc = parse_vf($_);
  foreach (@{$vfc->[0]}) {
    printf("%d=%s\n", $_->[2], $_->[1]);
  }
}

sub form_vf {
  my ($vfc) = @_; my (@lst);
  if ($op_zero) {{
    my $t = $vfc->[0][0] or last;
    ($t->[2] == 0) and last; # already zero
    info("change first fontmap id to zero (from " . $t->[2] . ")");
    substr($t->[0], 1, 1) = "\0"; $t->[2] = 0;
  }}
  foreach my $k (0 .. $#{$vfc->[0]}) {
    my $t = $vfc->[0][$k]; my $sfn = $t->[1];
    my $dfn = $dst_base[$k];
    (length($dfn) < 256) or error("TFM name too long", $dfn);
    info("id=".$t->[2], $sfn, $dfn);
    push(@lst, $t->[0], "\0" . chr(length($dfn)), $dfn);
  }
  my $tfm = join('', $vfc->[1], @lst, $vfc->[2]);
  return $tfm . ("\xf8" x (4 - length($tfm) % 4));
}

sub read_option {
  my ($op_info) = @_;
  $op_zero = 0;
  while ($ARGV[0] =~ m/^-/) {
    my $opt = shift(@ARGV);
    if ($opt =~ m/--?h(elp)?/) {
      show_usage();
    } elsif ($opt eq '-z' || $opt eq '--zero') {
      $op_zero = 1;
    } else {
      error("invalid option", $opt);
    }
  }
  ($src_main, $dst_main, @dst_base) = @ARGV;
  $src_main =~ s/\.vf$//;
  (defined $src_main) or error("no argument given");
  (!!$op_info == (!defined $dst_main))
    or error("wrong number of arguments");
  if (defined $dst_main) {
    $dst_main =~ s/\.vf$//;
    foreach (@dst_base) { s/\.tfm$//; }
    ($src_main ne $dst_main)
      or error("output vf name is same as input");
    (@dst_base) or error("no base tfm name given");
  }
}

#------------------------------------------------- go to main
package main;
main();
## EOF
