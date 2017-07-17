jfmutil
=======

Perl: Utility to process pTeX-extended TFM and VF

This program provides functionality to process data files (JFM and VF)
that form logical fonts used in (u)pTeX. The functions currently
available include:

  - The mutual conversion between Japanese virtual fonts (pairs of VF
    and JFM) and files in the “ZVP format”, which is an original text
    format representing data in virtual fonts. This function can be seen
    as counterpart to vftovp/vptovf programs.
  - The mutual conversion between VF files alone and files in the “ZVP0
    format”, which is a subset of the ZVP format.

### SYSTEM REQUIREMENTS

  - Perl interpreter: v5.8.1 or later.
  - The following commands from pTeX distribution:
      - kpsewhich
      - pltotf, tftopl

### LICENSE

This package is distributed under the MIT License.

### USAGE

    This is jfmutil v1.x.x <2017/xx/xx> by 'ZR'.
    [ZRTeXtor library v1.x.x <2017/xx/xx> by 'ZR']
    Usage: jfmutil vf2zvp0 [<options>] <in.vf> [<out.zvp0>]
           jfmutil zvp02vf [<options>] <in.zvp0> [<out.vf>]
           jfmutil vf2zvp [<options>] <in.vf> [<in.tfm> <out.zvp>]
           jfmutil zvp2vf [<options>] <in.zvp> [<out.vf> <out.tfm>]
           jfmutil zpl2tfm [<options>] <in.zvp0> [<out.vf>]
           jfmutil tfm2zpl [<options>] <in.zvp0> [<out.vf>]
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

Please refer to README-ja.md (in Japanese) for detail.

Revision History
----------------

  * Version 1.0.0 〈2017/07/17〉
      - The first public version (as jfmutil).
      - ZRTeXtor is of v1.4.0.

--------------------
Takayuki YATO (aka. "ZR")  
https://github.com/zr-tex8r
