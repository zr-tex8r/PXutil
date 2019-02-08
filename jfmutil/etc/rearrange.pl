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
# Copyright (c) 2019 Takayuki YATO (aka. "ZR")
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
  local ($_) = usage_message_org();
  my ($part1, $part2) = (<<"EOT1", <<"EOT2");

* ZVP Conversion
EOT1

* VF Replication
Usage: $prog_name vfcopy [<options>] <in.vf> <out.vf> <out_base.tfm>...
       $prog_name vfinfo [<options>] <in.vf>
       $prog_name jodel [<options>] <in.vf> <prefix>
Arguments:
  <in.vf>       input virtual font name
    N.B. Input TFM/VF files are searched by Kpathsea.
  <out.vf>      output virtual font name
  <out_base.tfm>  names of raw TFMs referred by the output virtual font;
                each entry replaces a font mapping in the input font in
                the given order, so the exactly same number of entries
                must be given as font mappings
  <prefix>      prefix of output font names (only for jodel)
Options:
  -z / --zero   change first fontmap id in vf to zero
  --uptex       assume input font to be for upTeX (only for jodel)
  --unicode     generate VF for 'direct-unicode' mode imposed by pxufont
                package; this option is supported only for upTeX fonts and
                thus implies '--uptex' (only for jodel)

* Common Options
  -h / --help     show this help message and exit
  -V / --version  show version
EOT2
  s/(Usage:)/$part1$1/; s/\z/$part2/;
  return $_;
};

%procs = (%procs,
  vfinfo  => \&main_vfinfo,
  vfcopy  => \&main_vfcopy,
  jodel   => \&main_jodel,
);

sub main_vfinfo {
  PXCopyFont::read_option('vfinfo');
  PXCopyFont::info_vf();
}

sub main_vfcopy {
  PXCopyFont::read_option('vfcopy');
  PXCopyFont::copy_vf();
}

sub main_jodel {
  PXCopyFont::read_option('jodel');
  PXCopyFont::jodel();
}

#------------------------------------------------- pxcopyfont stuffs
package PXCopyFont;

*error = *main::error;
*read_whole_file = *main::read_whole_file;
*write_whole_file = *main::write_whole_file;

our ($src_main, $dst_main, @dst_base, $op_zero, $op_uptex, $op_quiet);

sub info {
  ($op_quiet) or main::show_info(@_);
}

sub copy_vf {
  local $_ = read_whole_file(main::kpse("$src_main.vf"), 1) or error();
  my $vfc = parse_vf($_);
  my ($nb, $nb1) = (scalar(@{$vfc->[0]}), scalar(@dst_base));
  info("number of base TFMs in '$src_main'", $nb);
  if ($dst_base[-1] eq '...' && $nb1 <= $nb) {
    foreach ($nb1-1 .. $nb-1) { $dst_base[$_] = $vfc->[0][$_][1]; }
  } elsif ($nb != $nb1) {
    error("wrong number of base TFMs given", $nb1);
  }
  write_whole_file("$dst_main.vf", form_vf($vfc), 1) or error();
  write_whole_file("$dst_main.tfm",
      read_whole_file(main::kpse("$src_main.tfm"), 1), 1) or error();
  foreach my $k (0 .. $#dst_base) {
    my $sfn = $vfc->[0][$k][1]; my $dfn = $dst_base[$k];
    ($sfn ne $dfn) or next;
    write_whole_file("$dfn.tfm",
      read_whole_file(main::kpse("$sfn.tfm"), 1), 1) or error();
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
  local $_ = read_whole_file(main::kpse("$src_main.vf"), 1) or error();
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
  my ($proc) = @_;
  $op_zero = 0; $op_uptex = 0; $op_quiet = 0;
  while ($ARGV[0] =~ m/^-/) {
    my $opt = shift(@ARGV);
    if ($opt =~ m/--?h(elp)?/) {
      main::show_usage();
    } elsif ($opt =~ m/-(?:V|-version)?/) {
      main::show_version();
    } elsif ($opt eq '-z' || $opt eq '--zero') {
      $op_zero = 1;
    } elsif ($opt eq '--uptex') {
      $op_uptex = 1;
    } elsif ($opt eq '--unicode') {
      $op_uptex = 2;
    } elsif ($opt eq '--quiet') { # undocumented
      $op_quiet = 2;
    } else {
      error("invalid option", $opt);
    }
  }
  ($src_main, $dst_main, @dst_base) = @ARGV;
  $src_main =~ s/\.vf$//;
  (defined $src_main) or error("no argument given");
  (($proc eq 'vfinfo') ? (!defined $dst_main) :
   ($proc eq 'vfcopy') ? (defined $dst_main) :
   ($proc eq 'jodel') ? (defined $dst_main && $#dst_base == -1) : 1)
    or error("wrong number of arguments");
  if ($proc eq 'vfcopy') {
    $dst_main =~ s/\.vf$//;
    foreach (@dst_base) { s/\.tfm$//; }
    ($src_main ne $dst_main)
      or error("output vf name is same as input");
    (@dst_base) or error("no base tfm name given");
  }
  if ($proc eq 'jodel') {
    (!$op_zero) or error("invalid in jodel command", "-z/--zero");
    ($dst_main =~ m/^\w+$/)
      or error("bad characters in prefix", $dst_main);
    (length($dst_main) <= 100) or error("prefix too long", $dst_main);
  } else {
    (!$op_uptex) or error("invalid except in jodel command", "--uptex");
  }
}

#------------------------------- jodel

our %standard_vf = (
  'rml'             => [1, 'hXXXN-h'],
  'rmlv'            => [1, 'hXXXN-v'],
  'uprml-h'         => [2, 'uphXXXN-h'],
  'uprml-hq'        => [2, 'jodhXXX-hq'],
  'uprml-v'         => [2, 'uphXXXN-v'],
  'gbm'             => [1, 'hXXXN-h'],
  'gbmv'            => [1, 'hXXXN-v'],
  'upgbm-h'         => [2, 'uphXXXN-h'],
  'upgbm-hq'        => [2, 'jodhXXX-hq'],
  'upgbm-v'         => [2, 'uphXXXN-v'],
);
our @shape = (
  'minl', 'minr', 'minb', 'gothr', 'gothb', 'gotheb', 'mgothr'
);

our ($jengine, $jtate, @jvfname, %jvfidx, %jvfparsed);

sub jodel {
  jodel_analyze();
  if ($op_uptex == 2) {
    ($jengine == 2)
      or error("direct-unicode mode is only supported for pure upTeX fonts");
    foreach (values %standard_vf) {
      ($_->[1] =~ m/^jod/) and $_->[1] =~ s/jod/zu-jod/;
    }
  }
  foreach (@shape) {
    jodel_generate($_, '');
    jodel_generate($_, 'n');
  }
}

sub jodel_vf_name {
  my ($shp, $nn, $idx) = @_;
  my $zu = ($op_uptex == 2) ? 'zu-' : '';
  my $i = ($idx > 0) ? "$idx" : '';
  my $up = (jodel_for_uptex()) ? 'up' : '';
  my $hv = ($jtate) ? 'v' : 'h';
  return "$zu$dst_main-$i-${up}nml$shp$nn-$hv";
}
sub jodel_tfm_name {
  my ($shp, $nn, $nam) = @_;
  $nam =~ s/XXX/\Q$shp\E/; $nam =~ s/N/\Q$nn\E/;
  return $nam;
}
sub jodel_for_uptex {
  return ($jengine == 2 || ($jengine == 3 && $op_uptex));
}

{
  my (%jkpse);
  sub jodel_kpse {
    my ($in) = @_;
    if (exists $jkpse{$in}) { return $jkpse{$in}; }
    my $out = main::kpse($in); $jkpse{$in} = $out;
    return $out;
  }
}

sub jodel_clone {
  my ($val) = @_;
  if (ref($val) eq '') {
    return $val;
  } elsif (ref($val) eq 'ARRAY') {
    return [ map { jodel_clone($_) } (@$val) ];
  } else { error("OOPS", 98, ref($val)); }
}

sub jodel_analyze {
  local ($_);
  info("**** Analyze VF '$src_main'");
  $_ = read_whole_file(jodel_kpse("$src_main.tfm"), 1) or error();
  $jtate = (unpack('n', $_) == 9);
  info("direction", ($jtate) ? 'tate' : 'yoko');
  @jvfname = ($src_main); $jengine = 0;
  info("base TFMs", "");
  for (my $i = 0; $i <= $#jvfname; $i++) {
    my $nvf = $jvfname[$i];
    $_ = read_whole_file(jodel_kpse("$nvf.vf"), 1)
      or error(($i > 0) ? ("non-standard raw TFM", $nvf) : ());
    $_ = parse_vf($_) or error();
    $jvfidx{$nvf} = $i; $jvfparsed{$nvf} = $_;
    my @lst = map { $_->[1] } @{$_->[0]};
    info("  $nvf -> @lst");
    foreach (@lst) {
      if (exists $standard_vf{$_}) {
        $jengine |= $standard_vf{$_}[0];
        next;
      }
      (exists $jvfidx{$_}) and next;
      push(@jvfname, $_);
    }
  }
  my $eng = (jodel_for_uptex()) ? 'upTeX' : 'pTeX';
  ($jengine == 3) and $eng .= ' (mixed)';
  info("engine", $eng);
}

sub jodel_generate {
  my ($shp, $nn) = @_; local ($_);
  my $dnvf0 = jodel_vf_name($shp, $nn, 0);
  info("*** Generate VF '$dnvf0'");
  foreach my $i (0 .. $#jvfname) {
    my $snvf = $jvfname[$i];
    my $dnvf = jodel_vf_name($shp, $nn, $i);
    my $vfc = jodel_clone($jvfparsed{$snvf});
    my (@slst, @dlst);
    foreach my $e (@{$vfc->[0]}) {
      my $sbas = $e->[1]; my $dbas;
      if (exists $standard_vf{$sbas}) {
        $dbas = jodel_tfm_name($shp, $nn, $standard_vf{$sbas}[1]);
      } elsif (exists $jvfidx{$sbas}) {
        $dbas = jodel_vf_name($shp, $nn, $jvfidx{$sbas});
      } else { error("OOPS", 95, "$sbas"); }
      push(@slst, $sbas); push(@dlst, $dbas);
      $e->[1] = $dbas;
    }
    info("from", "$snvf -> @slst");
    info("  to", "$dnvf -> @dlst");
    write_whole_file("$dnvf.vf", jodel_form_vf($vfc), 1) or error();
    write_whole_file("$dnvf.tfm",
        read_whole_file(jodel_kpse("$snvf.tfm"), 1), 1) or error();
  }
}

sub jodel_form_vf {
  my ($vfc) = @_; my (@lst);
  foreach my $k (0 .. $#{$vfc->[0]}) {
    my $t = $vfc->[0][$k]; my $dfn = $t->[1];
    push(@lst, $t->[0], "\0" . chr(length($dfn)), $dfn);
  }
  my $tfm = join('', $vfc->[1], @lst, $vfc->[2]);
  return $tfm . ("\xf8" x (4 - length($tfm) % 4));
}

#------------------------------------------------- go to main
package main;
main();
## EOF
