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
  - The replication of virtual fonts with different names, where the
    referred TFM names in the VF will be suitably revised.

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

    * ZVP Conversion
    Usage: jfmutil vf2zvp0 [<options>] <in.vf> [<out.zvp0>]
           jfmutil zvp02vf [<options>] <in.zvp0> [<out.vf>]
           jfmutil vf2zvp [<options>] <in.vf> [<in.tfm> <out.zvp>]
           jfmutil zvp2vf [<options>] <in.zvp> [<out.vf> <out.tfm>]
           jfmutil zpl2tfm [<options>] <in.zvp0> [<out.vf>]
           jfmutil tfm2zpl [<options>] <in.zvp0> [<out.vf>]
    Arguments:
      <in.xxx>        input files
        N.B. Input TFM/VF files are searched by Kpathsea. (ZVP/ZVP9 are not.)
      <out.xxx>       output files
    Options:
           --hex      output charcode in 'H' form [default]
      -o / --octal    output charcode in 'O' form
      --uptool        use upTeX tools (uppltotf etc.)
      The following options affect interpretation of 'K' form.
      --kanji=ENC     set source encoding: ENC=jis/sjis/euc/utf8/none
      --kanji-internal=ENC set internal encoding: ENC=jis/unicode/none
      -j / --jis      == --kanji=jis --kanji-internal=jis
      -u / --unicode  == --kanji=utf8 --kanji-internal=unicode
      -E / --no-encoding == --kanji=none --kanji-internal=none
    * VF Replication
    Usage: jfmutil vfcopy [<options>] <in.vf> <out.zvf> <out_base.tfm>...
           jfmutil vfinfo [<options>] <in.vf>
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


Please refer to README-ja.md (in Japanese) for detail.

Revision History
----------------

  * Version 1.1.0 〈2017/09/16〉
      - Add subcommands `vfinfo` and `vfcopy`.

  * Version 1.0.1 〈2017/07/21〉
      - Add shebang line.

  * Version 1.0.0 〈2017/07/17〉
      - The first public version (as jfmutil).
      - ZRTeXtor is of v1.4.0.

--------------------
Takayuki YATO (aka. "ZR")  
https://github.com/zr-tex8r
