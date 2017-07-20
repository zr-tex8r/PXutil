#
# pxutil.pl
#
use strict;
BEGIN { $_ = $0; s|^(.*)/.*$|$1|; unshift(@INC, $_); }
use ZRTeXtor ':all';
use Encode qw(encode decode);
my $prog_name = 'pxutil';
my $version = '1.0.1';
my $mod_date = '2017/07/21';
#use Data::Dump 'dump';
#
my ($sw_hex, $sw_uptool, $sw_noencout, $inenc, $exenc);
my ($proc_name, $infile, $in2file ,$outfile, $out2file);

#### main procedure

my %procs = (
  vf2zvp0 => \&main_vf2zvp0,
  zvp02vf => \&main_zvp02vf,
  vf2zvp  => \&main_vf2zvp,
  zvp2vf  => \&main_zvp2vf,
  tfm2zpl => \&main_tfm2zpl,
  zpl2tfm => \&main_zpl2tfm,
);

sub main {
  my ($proc);
  if (defined textool_error()) { error(); }
  if ((($proc_name) = $ARGV[0] =~ m/^:?(\w+)$/)
      && defined($proc = $procs{$proc_name})) {
    shift(@ARGV); $proc->();
  } else {
    show_usage();
  }
}

sub main_vf2zvp0 {
  my ($t);
  read_option();
  $t = read_whole_file(kpse($infile), 1) or error();
  $t = vf_parse($t) or error();
  $t = pl_form($t) or error();
  write_whole_file($outfile, $t) or error();
}

sub main_zvp02vf {
  my ($t);
  read_option();
  $t = read_whole_file(kpse($infile)) or error();
  $t = pl_parse($t) or error();
  $t = vf_form($t) or error();
  write_whole_file($outfile, $t, 1) or error();
}

sub main_zvp2vf {
  my ($t, $u);
  read_option();
  if ($sw_uptool) { jfm_use_uptex_tool(1); }
  $t = read_whole_file(kpse($infile)) or error();
  $t = pl_parse($t) or error();
  ($t, $u) = vf_form_ex($t) or error();
  write_whole_file($outfile, $t, 1) or error();
  write_whole_file($out2file, $u, 1) or error();
}
sub main_vf2zvp {
  my ($t, $vf, $tfm);
  read_option();
  if ($sw_uptool) { jfm_use_uptex_tool(1); }
  $vf = read_whole_file(kpse($infile), 1) or error();
  $tfm = read_whole_file(kpse($in2file), 1) or error();
  $t = vf_parse_ex($vf, $tfm) or error();
  $t = pl_form($t) or error();
  write_whole_file($outfile, $t) or error();
}

sub main_tfm2zpl {
  my ($t);
  read_option();
  if ($sw_uptool) { jfm_use_uptex_tool(1); }
  $t = read_whole_file(kpse($infile), 1) or error();
  $t = jfm_parse($t) or error();
  $t = pl_form($t) or error();
  write_whole_file($outfile, $t) or error();
}


sub main_zpl2tfm {
  my ($t);
  read_option();
  if ($sw_uptool) { jfm_use_uptex_tool(1); }
  $t = read_whole_file(kpse($infile)) or error();
  $t = pl_parse($t) or error();
  $t = jfm_form($t) or error();
  write_whole_file($outfile, $t, 1) or error();
}

sub show_usage {
  my ($v, $m) = @_;
  ($v, $m) = textool_version() or error();
  print <<"END"; exit;
This is $prog_name v$version <$mod_date> by 'ZR'.
[ZRTeXtor library v$v <$m> by 'ZR']
Usage: $prog_name vf2zvp0 [<options>] <in.vf> [<out.zvp0>]
       $prog_name zvp02vf [<options>] <in.zvp0> [<out.vf>]
       $prog_name vf2zvp [<options>] <in.vf> [<in.tfm> <out.zvp>]
       $prog_name zvp2vf [<options>] <in.zvp> [<out.vf> <out.tfm>]
       $prog_name zpl2tfm [<options>] <in.zvp0> [<out.vf>]
       $prog_name tfm2zpl [<options>] <in.zvp0> [<out.vf>]
  VF and TFM files are searched by kpsewhich.
       --hex      output charcode in 'H' form [default]
  -o / --octal    output charcode in 'O' form
  --uptool        use upTeX tools (uppltotf etc.)
  The following options affect interpretation of 'K' form.
  --kanji=ENC     set source encoding: ENC=jis/sjis/euc/utf8/none
  --kanji-internal=ENC set internal encoding: ENC=jis/unicode/none
  -j / --jis      == --kanji=jis --kanji-internal=jis
  -u / --unicode  == --kanji=utf8 --kanji-internal=unicode
  -E / --no-encoding == --kanji=none --kanji-internal=none
END
}

#### command-line options

sub read_option {
  my ($opt, $arg);
  $sw_hex = 1; $sw_uptool = 0;
  while ($ARGV[0] =~ m/^-/) {
    $opt = shift(@ARGV);
    if ($opt =~ m/--?h(elp)?/) {
      show_usage();
    } elsif ($opt eq '--hex') {
      $sw_hex = 1;
    } elsif ($opt eq '--octal' || $opt eq '-o') {
      $sw_hex = 0;
    } elsif ($opt eq '--uptool') {
      $sw_uptool = 1;
    } elsif ($opt eq '--no-encoding' || $opt eq '-E') {
      ($exenc, $inenc) = ('none', 'none');
    } elsif ($opt eq '--jis' || $opt eq '-j') {
      ($exenc, $inenc) = ('jis', 'jis');
    } elsif ($opt eq '--unicode' || $opt eq '-u') {
      ($exenc, $inenc) = ('utf8', 'unicode');
    } elsif (($arg) = $opt =~ m/^--kanji[=:](.*)$/) {
      $exenc = $arg;
    } elsif (($arg) = $opt =~ m/^--kanji-internal[=:](.*)$/) {
      $inenc = $arg;
    } else {
      error("invalid option", $opt);
    }
  }
  jcode_set($exenc)
    or error("unknown source kanji code: $exenc");
  jcode_set(undef, $inenc)
    or error("unknown internal kanji code: $inenc");
  #if ($inenc eq 'unicode') { $sw_uptool = 1; }
  if ($sw_hex) { pl_prefer_hex(1); }
  (0 <= $#ARGV && $#ARGV <= 1)
    or error("wrong number of arguments");
  if ($proc_name eq 'vf2zvp0') {
    ($infile, $outfile) = fix_pathname(".vf", ".zvp0");
  } elsif ($proc_name eq 'zvp02vf') {
    ($infile, $outfile) = fix_pathname(".zvp0", ".vf");
  } elsif ($proc_name eq 'vf2zvp') {
    ($infile, $in2file, $outfile) =
      fix_pathname(".vf", ".tfm", ".zvp");
  } elsif ($proc_name eq 'zvp2vf') {
    ($infile, $outfile, $out2file) =
      fix_pathname(".zvp", ".vf", ".tfm");
  } elsif ($proc_name eq 'tfm2zpl') {
    ($infile, $outfile) = fix_pathname(".tfm", ".zpl");
  } elsif ($proc_name eq 'zpl2tfm') {
    ($infile, $outfile) = fix_pathname(".zpl", ".tfm");
  }
  ($infile ne $outfile)
    or error("input and output file have same name", $infile);
}

sub fix_pathname {
  my (@ext) = @_; my (@path);
  @{$path[0]} = split_path($ARGV[0]);
  (defined $path[0][2]) or $path[0][2] = $ext[0];
  foreach (1 .. $#ext) {
    if (defined $ARGV[$_]) {
      @{$path[$_]} = split_path($ARGV[$_]);
      (defined $path[$_][2]) or $path[$_][2] = $ext[$_];
    } else {
      @{$path[$_]} = (undef, $path[0][1], $ext[$_]);
    }
  }
  return map { join('', @{$path[$_]}) } (0 .. $#_);
}

sub split_path {
  my ($pnam) = @_; my ($dnam, $fbas, $ext);
  ($dnam, $fbas) = ($pnam =~ m|^(.*/)(.*)$|) ? ($1, $2) :
                   (undef, $pnam);
  ($fbas, $ext) = ($fbas =~ m|^(.+)(\..*)$|) ? ($1, $2) :
                   ($fbas, undef);
  return ($dnam, $fbas, $ext);
}

#### user interface

sub show_info {
  print STDERR (join(": ", $prog_name, @_), "\n");
}

sub alert {
  show_info("warning", @_);
}

sub error {
  show_info((@_) ? (@_) : textool_error());
  exit(-1);
}

#### go to main
main();
# EOF
