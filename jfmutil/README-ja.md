jfmutil
=======

Perl： pTeX の TFM/VF を操作するユーティリティ

(u)pTeX の論理フォントに関するデータファイル（JFM および VF）を操作する
種々の機能を提供するツールである。現在のところ、次の機能が利用できる。

  - 和文の仮想フォント（VF・JFM の組）に対応する独自仕様のテキスト形式で
    ある「ZVP 形式」と仮想フォントとの間の相互変換。今まで、和文 VF の
    生成・編集はそれに対応するテキスト形式がなかったため非常に面倒で
    あった。ZVP 形式を使うことで、和文 VF の新規作成や編集が容易になる
    ことが期待できる。
  - ZVP 中の VF に直接対応する部分を抜き出した「ZVP0 形式」と VF (和文/
    欧文)との間の相互変換。
  - 仮想フォントの別名での複製。この場合、VF 中に記録された参照 TFM 名も
    適切に変更される。

### 前提環境

  - Perl 処理系: v5.8.1 以降
  - pTeX の配布に含まれる以下のコマンド
      - kpsewhich
      - ppltotf, ptftopl

### 参考サイト

  - PXutil パッケージ  
    En toi Pythmeni tes TeXnopoleos ～電脳世界の奥底にて～  
    <http://zrbabbler.sp.land.to/pxutil.html>  
    pxutil を用いた和文仮想フォントの改変の方法について解説されている。
    jfmutil は pxutil の上位互換なので、この記事の内容は単にコマンド名を
    `pxutil` から `jfmutil` に変えることでそのまま通用する。

  - PXcopyfont パッケージ  
    En toi Pythmeni tes TeXnopoleos ～電脳世界の奥底にて～  
    <http://zrbabbler.sp.land.to/pxcopyfont.html>  
    pxcopyfont を用いた仮想フォントの複製の方法について解説されている。
    pxcopyfont と jfmutil の関係については後述。

### pxutil との関係

jfmutil の ZVP 関連の機能は [pxutil] と等価である。pxutil の動作のためには
ZRTeXtor モジュールを別途インストールする必要があった。CTAN に登録するに
あたって単体で動作するプログラムの方がよいと考え、pxutil に ZRTeXtor の
コードの一部を併合したものが当初の jfmutil である。

[pxutil]: https://github.com/zr-tex8r/PXutil

jfmutil と pxutil の相違点は次のとおりである：

  - jfmutil は ZRTeXtor の設定ファイル（`ZRTeXtor.cfg`）を参照しない。
    設定対象の値は全て既定値が使われる。
  - ただし、漢字コードは外部・内部ともに“無効”(`none`）を指定している。
    このため、`-E` オプション指定が既定の状態となる。
  - なお、ZRTeXtor の 1.4.0 版より、設定項目 `tftopl`/`pltotf` の既定値は
    `ptftopl`/`ppltotf` となっている。

### pxcopyfont との関係

jfmutil の仮想フォント複製の機能は [pxcopyfont] から移植したものである。

  - `jfmutil vfinfo in[.vf]`（VF ファイルの情報出力）は  
    `pxcopyfont in` と情報を出力する。ただし出力形式は両者で異なる。
  - `jfmutil vfcopy in[.vf] out[.vf] base[.tfm]...`（VF 複製）は  
    `pxcopyfont in out base...` と等価である。

### ライセンス

MIT ライセンス


機能解説：VF 複製
-----------------

仮想フォント（VF と TFM の組）のファイルを別の名前でコピーする。一般に、
VF ファイルの中には参照する TFM の名前が記録されているが、コピーの際には
この TFM 名はコピー先ものに変更される。（従って、VF ファイルについては、
コピー元とコピー先はバイナリ同一にはならない。）

### 使用法

    jfmutil vfcopy [<オプション>] <入力.vf> <出力.vf> <出力.tfm>...
    jfmutil vfinfo [<オプション>] <入力.vf>

※既定の拡張子は省略可能。

`vfinfo` サブコマンドは `入力.vf` の参照 TFM の情報を出力する。例えば、
upTeX 標準の `upjpnrm-h.vf` の場合、以下の出力になる：

    0=uprml-h
    2=upjisr-hq

`vfcopy` サブコマンドは `入力.vf` とそれが参照する TFM 群の組を、
`出力.vf` とその後の引数で指定した TFM 群にコピーする。例えば

    jfmutil vfcopy upjpnrm-h myjpnrm-h myrml-h myjisr-hq

は以下の動作を行う：

  - `upjpnrm-h.vf` を `myjpnrm-h.vf` に改変付でコピーする。
  - `uprml-h.tfm` を `myrml-h.tfm` にコピーする。
  - `upjisr-hq.tfm` を `myjisr-hq.tfm` にコピーする。

引数中の出力 TFM ファイル名の列は途中に `...` を書いて以降を省略できる。
この場合、対応する入力 TFM ファイル（入力 VF に記録されたもの）と同じ名前
が使われる。

※TFM について入力と出力の名前が同じ場合は、ファイルのコピーは行わない。


機能解説：ZVP 変換
------------------

### TeX のフォントファイルの形式

<pre>
    使用法について述べる前に、このソフトウェアが扱うファイル形式について
    説明しておく。

    ・バイナリ形式
      TeX、および dvipdfmx 等の DVI ウェアが実際に使用するファイルの形式
      である。

      TFM (欧文 TFM; 拡張子 .tfm)
        フォントのメトリックデータが記載されている。
      JFM (和文 TFM; 拡張子 .tfm)
        和文フォントの為の TFM 形式。
      VF (拡張子 .vf)
        TeX システムが用いる仮想フォントの形式。実際には、VF には必ず対応
        する TFM (ベース名が一致する)があり、この 2 つが仮想フォントを
        構成している。VF 形式は欧文と和文の両方で用いられる。

    ・テキスト形式
      上記のバイナリ形式のデータを人間が読めるようにテキストで表したもの。
      テキスト形式とバイナリ形式の間の相互変換をするソフトウェアが TeX
      システムには用意されている。(*) 印は作者(ZR)が提唱する独自の形式で
      これを扱うのに pxutil が必要である。

      PL (拡張子 .pl)
        (欧文) TFM に対応する形式。
      JPL (和文 PL; 拡張子 .pl)
        JFM に対応する形式。
      VPL (拡張子 .vpl)
        欧文仮想フォント(欧文 TFM と VF の組)に対応する形式。形式の相互
        変換は必ず TFM と VF との組の間で行う。
      ZPL (拡張子 .zpl) (*)
        JPL を少し拡張した形式。やはり JFM と対応する。
      ZVP0 (拡張子 .zvp0) (*)
        VF と直接対応する形式。VPL と異なり、TFM に相当するデータを持って
        いない。だから欧文と和文で共通して用いられる。
      ZVP (拡張子 .zvp)
        和文仮想フォント(JFM と VF の組)に対応する形式。ZPL と ZVP0 を
        統合した形をもつ。
</pre>

### 使用法

<pre>
    pxutil vf2zvp [<オプション>] <入力.vf> [<入力.tfm> <出力.zvp>]
      VF と JFM から ZVP へ変換。
    pxutil zvp2vf [<オプション>] <入力.zvp> [<出力.vf> <出力.tfm>]
      ZVP から VF と JFM へ変換。
    pxutil vf2zvp0 [<オプション>] <入力.vf> [<出力.zvp0>]
      VF から ZVP0 へ変換。
    pxutil zvp02vf [<オプション>] <入力.zvp0> [<出力.vf>]
      ZVP0 から VF へ変換。
    pxutil zpl2tfm [<オプション>] <入力.zpl> [<出力.tfm>]
      ZPL から TFM へ変換。
    pxutil tfm2zpl [<オプション>] <入力.tfm> [<出力.zpl>]
      TFM から ZPL へ変換。

    - TFM と VF 形式のファイルは、kpathsearch の探索の対象となる。
    - 出力ファイル名を省略した場合は、入力ファイルの拡張子を変更したもの
      が使われる。tftopl のように標準出力に書き出すことはない。
</pre>

### オプション

<pre>
    ・出力整数値形式の選択

      テキスト形式のファイルを出力する時に、整数値の形式として 'H' (16進)
      と 'O' (8進) が選択できる箇所がある(主に文字コードを表す数値。)
      ここでどちらの形式を用いるかを指定する。

      --hex  (既定値)
        'H'(16進) 形式を指定する。
      --octal / -o
        'O'(8進) 形式を指定する。

      注意事項:
      - 形式が 'H' か 'O' の一方に固定された箇所もある。例えば CHECKSUM
        は必ず 'O' 形式を用いる。
      - 入力の際には、論理的に可能な全ての形式が受理される。'D'(10 進)で
        256 以上の値を指定することも可能。ただし、内部で pltotf を呼び出し
        ている関係で形式が制限されることもある。

    ・漢字コード指定
    
      --kanji=<値>
        外部漢字コードを指定する。<値>は以下のとおり。
        jis   ISO-2022-JP (既定値)
        sjis  Shift_JIS
        euc   EUC-JP
        utf8  UTF-8
        none  無効(詳細は後述)
      --kanji-internal=<値>
        内部漢字コードを指定する。<値>は以下のとおり。
        jis     JIS X 0208 (既定値)
        unicode Unicode
        none    無効(詳細は後述)
      --unicode / -u
        --kanji=utf8 --kanji-internal=unicode と等価。Unicode 和文
        フォントを扱う場合の設定。
      --no-encoding / -E
        --kanji=none --kanji-internal=none と等価。

      テキスト形式のファイルで「文字コード値の指定を文字を直接書いて行う
      場合」が存在する。例えば、整数値の 'K' 形式や、JPL の CHARSINTYPE
      の指定等である。「外部漢字コード」はテキストファイルの文字を読む
      のに使われる漢字コードであり、「内部漢字コード」は文字をバイナリ
      形式で用いるコード値に変換する時に使われる漢字コードである。
      
      例えば、--kanji=sjis --kanji-internal=unicode と設定されている場合
      を考える。この場合、'K' 形式を含むテキスト形式の入力を扱うには、
      そのファイルの漢字コードを Shift_JIS にする必要がある。そして、
      'K あ' という整数値があった場合、<あ> の Unicode 値である 0x3042
      が指定された(つまり 'H 3042' と等価)とみなされる。
      
      このように、漢字コードの指定が意味をもつのは、「文字の直接指定」
      を入力のテキスト形式用いる場合に限られる。(pxutil は出力中で文字
      の直接指定を用いることはない。) --kanji おとび --kanji-internal
      の値 none は「文字の直接指定」を無効にする設定であり、片方が none
      に設定している場合、自動的に他方も none になる(つまり --no-encoding
      と同じ)。この指定の場合に「文字の直接指定」を使おうとするとエラー
      になる。

      注意事項:
      - 当然ながら、'K' 以外の整数値形式は文字コード指定の影響を受けない。
        例えば、'H 3042' は常に数値 0x3042 を表す。
      - JIS X 0208 と Unicode の間の文字の対応は JIS X 0221 の規定に従う。
        ただ、TeX 関係のソフトウェアで別の方式を用いるものもあるので、
        両者の間のコード変換は避けた方が無難である。

    ・その他
      --uptool
        ppltotf/ptftopl に代わりに uppltotf/uptftopl を用いる。
      --lenient
        VF 解析時に生じた軽微な問題をエラーと扱わない。
</pre>

### ZPL 形式の仕様

<pre>
    ・概要

      ZPL 形式は JPL 形式を少しだけ拡張したもので、元の JPL 形式と同じく
      JFM 形式に対応する。開発経緯の上では、ZVP 形式の JFM に相当する部分
      を抜き出したものに相当する。以下では、JPL 形式との相違点のみを説明
      する。

    ・CHARSINTYPE の拡張

      (CHARSINTYPE <整数t> <文字リスト>)
      CHARSINTYPE は上記の書式をもち、TYPE t に属する文字コードの集合を
      規定する要素である。<文字リスト> は 1 つ以上の「文字」を空白で
      区切って連ねたもので、「文字」は以下の形式で指定できる。

      文字を直接書く: ASCII 以外の文字を書くと、整数値の 'K' 形式と同様
        にその文字の内部漢字コード値を指定したことになる。外部および内部
        漢字コードの設定に依存する。
      Jxxxx 形式: 'J' の後に 4 桁の 16 進数字を書いた文字列は、その数字が
        表す数値を JIS コード値とする文字の内部漢字コード値を表す。
      Uxxxx 形式: 'U' の後に 4 桁の 16 進数字を書いた文字列は、その数字が
        表す数値を Unicode 値とする文字の内部漢字コード値を表す。
      Xxxxx 形式: 'X' の後に 4 桁の 16 進数字を書いた文字列は、その数字が
        表す数値そのものを表す。(内部漢字コードの設定と無関係。)
      PL の整数値指定の形式: PL の他の場所で使われる 'H 1234' 等の書式が
        使え、表す数値も同じである。
      CTRANGE 要素: 次の書式をもち、a 以上 b 以下の全ての整数を表す。
          (CTRANGE <整数a> <整数b>)
          
      例: --kanji-internal=unicode の下で、
        (CHARSINTYPE D 2 あ J3021 D 200 U1234 X5678
                         (CTRANGE H FF11 H FF13))
      という指定で Type 2 に指定される文字コードは
        0x3042 (<あ> = Unicode 0x3042),
        0x4E9C (JIS 0x3021 = <亜> = Unicode 0x4E9C), 0xC8 (= 200),
        0x1234 ('U' はそのまま), 0x5678, 0xFF11, 0xFF12, 0xFF13
      である。

      参考までに、JPL 形式と比較すると以下のようになる。「～の JPL」は
      「～付属の pltotf (実際のコマンド名は異なる可能性あり)で処理できる
      JPL 形式」を指す。upTeX において JFM 形式は拡張されておらず pTeX
      のそれと同じ仕様であることに注意。

         ファイル形式    直接  Jxxxx  Uxxxx  ほか
        pTeX の JPL       ○    ○     ×     ×
        upTeX の JPL      ○    ○     ○     ×
        ZPL               ○    ○     ○     ○
</pre>

### ZVP0 形式の仕様

<pre>
    ・概要

      ZVP0 形式は、バイナリの VF 形式に直接対応するテキスト形式で、VPL
      形式のうちの VF に記述されている項目だけを抜き出した格好をしている。
      具体的には、VPL で現れる要素のうち次のものからなる。

        VTITLE
        DESIGNSIZE
        CHECKSUM
        MAPFONT
        CHARACTER

      このうち、CHARACTER の中の MAP に若干の拡張を含んでいるので、それ
      について以下で説明する。残りの要素の仕様は VPL と同じである。

    ・MAP 中の文字出力命令に対する拡張
    
      MAP 要素は、仮想フォントの 1 つの文字に対して、それを表現する DVI
      命令の列を指定するものである。この中で使われる SETCHAR 要素(DVI
      の setchar/set1～4 命令と対応する)は次の書式をもち、「文字コード
      c の文字を出力する」ことを意味する。
        (SETCHAR <整数 c>)
      ZVP0 形式では以下のような引数のない形式が許される。
        (SETCHAR)
      この場合、出力する文字は、「当該の SETCHAR を含む CHARACTER 要素
      の対象の文字」になる。

      例えば、以下の記述で、"(SETCHAR)" は "(SETCHAR H 2122)" と同値と
      解釈される。

        (CHARACTER H 2122
           (CHARWD R 0.5)
           (MAP
              (SETCHAR)
              )
           )
</pre>

### ZVP 形式の仕様

<pre>
    ・概要

      ZVP 形式は和文の仮想フォントに対応するテキスト形式で、
         要素             JFM VF
        DIRECTION         ○  －
        VTITLE            －  ○
        FAMILY            ○  －
        FACE              ○  －
        HEADER            ○  －
        CODINGSCHEME      ○  －
        DESIGNUNITS       ○  －
        DESIGNSIZE        ○  ○
        CHECKSUM          ○  ○
        SEVENBITSAFEFLAG  ○  －
        FONTDIMEN         ○  －
        BOUNDARYCHAR      ○  －
        MAPFONT           －  ○
        LIGTABLE          ○  －
        GLUEKERN          ○  －
        CODESPACE         －  ○  新設
        CHARSINTYPE       ○  ○  拡張
        CHARSINSUBTYPE    －  ○  新設
        TYPE              ○  ○  拡張
        SUBTYPE           －  ○  新設
        CHARACTER         ○  ○  新設

      以下で、新設または拡張された要素の説明を行うが、その前に新たに導入
      された概念について説明する。

    ・Subtype

      ZVP0 形式のところで説明した SETFONT の拡張書式を使うと、全く同一の
      MAP 指定をもつ文字が多く出ることになる。例えば、最も頻繁に発生する
      「既定のフォントについて要求された文字を出す」というのは
        (MAP (SETCHAR) )
      と表すことができる。そこで、1 つの Type の中で同一の MAP 指定をもつ
      文字を Subtype としてまとめることにする。すなわち、Type が同じで
      Subtype が異なる文字は、JFM では全く同じ振る舞いをする(つまり同じ
      メトリックを持ち GLUEKERN での扱いも同じ)が、MAP 指定だけが異なる。
      こうすることで、VPL での CHARACTER の指定を Subtype 毎にまとめて
      行うことができるようになる。
      
      なお、Subtype は ZVP の中だけに存在する概念で、その値は JFM や VF
      の中のどの情報とも対応しない。MAP 指定が同じものは同じ Subtype 値
      を持つという点だけに意味がある。Subtype の有効な値は 0～255 である。

    ・コード空間

      JPL (JFM でも同様)では、Type が 0 以外の文字を列挙して、それ以外の
      文字を Type 0 の文字と扱っている。従って、そのフォントにおいてどの
      コードが有効かということは明示されていない。これに対して、VPL (VF)
      では仮想フォントで有効な文字の全てについて CHARACTER 要素が必要と
      される。従って、上で述べたように Type と Subtype を用いて CHARACTER
      を一括指定しようとすると、有効な文字の集合(コード空間)の情報が必要
      となる。

      引き続いて、新設または拡張された要素の説明を行う。

    ・(CODESPACE <文字リスト>)
      (CODESPACE <コード空間識別子>)
    
      コード空間を指定する。<文字リスト> の書式は ZPL の CHARSINTYPE と
      同じ。特定のコード空間の設定に対しては下記の <コード空間識別子>
      による指定も可能である。
        - GL94DB: 上位バイト、下位バイトともに 0x21～0x7E の 2 バイト値
          全体。pTeX の和文フォントで通常使われる設定。(CODESPACE の
          既定値はこれである)
        - UNICODE-BMP: 0～0xFFFF。Unicode の BMP の全体。

    ・(CHARSINTYPE <整数t> <文字リスト>)

      Type t の文字の集合を指定する。t は 1～255 の整数。

    ・(CHARSINSUBTYPE <整数t> <整数s> <文字リスト>)

      Type t、Subtype s の文字の集合を指定する。t は 0～255 の整数。
      s は 1～255 の整数。

    ・(TYPE <整数t> <要素>...)

      Type t の文字に対する情報を記述する。t は 0～255 の整数。
      
      要素として以下のものが指定できる。
        - CHARWD, CHARHT, CHARDP, CHARIC : これは Type t の文字全体に
          対して適用される。
        - MAP : これは Type t、Subtype 0 の文字に適用される。

    ・(SUBTYPE <整数t> <整数s> <MAP要素>)

      Type t、Subtype の文字に対する MAP を記述する。t は 0～255 の整数。
      s は 1～255 の整数。

    ・(CHARACTER <整数c> <MAP要素>)

      コード値 c の文字に対する MAP を記述する。文字 c の Type はこの
      要素の記述に影響しない。(つまり、CHARSINTYPE で指定した値、どこに
      もない場合は 0。）文字 c だけからなる Subtype を仮想的に作ったの
      と同じである。

      各 Subtype の文字の情報がどこにあるかをまとめた。以下の表で、t は
      0 以外の Type、s は 0 以外の Subtype を表す。煩雑なように見えるが、
      「本則を Type/Subtype 0 に書き、例外をそれ以外に書く」という設計
      上このような結果になっている。これにより、文字リストを書くときに
      CTRANGE が最大限活用できるようになり、また従来の JPL からの変更点
      が最小限になると考えている。

      Type Subtype   文字集合              メトリック  MAP指定
        0    0  (CODESPACE)から             (TYPE 0)  (TYPE 0)
                全ての(CHARSINTYPE t)と
                全ての(CHARSINSUBTYPE 0 s)
                を除いたもの
        0    s  (CHARSINSUBTYPE 0 s)        (TYPE 0)  (SUBTYPE 0 s)
        t    0  (CHARSINTYPE t)から         (TYPE t)  (TYPE t)
                全ての(CHARSINSUBTYPE t s)
                を除いたもの。
        t    s  (CHARSINSUBTYPE t s)        (TYPE t)  (SUBTYPE t s)
</pre>

更新履歴
--------

  * Version 1.3.2 〈2021/05/29〉
      - ZRTeXtor 1.8.0 版に同期。変更点は：
          + charpacket のない VF を許容する。

  * Version 1.3.1 〈2020/05/04〉
      - `jodel` を jodhminrn フォントに対応させる。

  * Version 1.3.0 〈2020/05/03〉
      - 一部のサブコマンドに `--compact` オプションを追加。
      - `compact` コマンドを追加。
      - バグ修正。

  * Version 1.2.4 〈2020/05/02〉

  * Version 1.2.3 〈2019/09/02〉
      - バグ・不具合の修正。

  * Version 1.2.2 〈2019/02/09〉
      - バグ修正。

  * Version 1.2.1 〈2019/02/08〉
      - (試験的) `jodel` コマンドを追加。

  * Version 1.2.0 〈2019/02/02〉
      - `--lenient` オプションを追加。

  * Version 1.1.2 〈2018/01/21〉
      - ZRTeXtor 1.5.0 版に同期。変更点は：
          + JFM 形式について最近行われた「非 BMP 文字を非既定文字クラスに
            含めることを可能にする」拡張をサポートした。

  * Version 1.1.1 〈2018/01/20〉
      - バグ修正。

  * Version 1.1.0 〈2017/09/16〉
      - pxcopyfont 由来の機能（`vfinfo`、`vfcopy` サブコマンド）を追加。

  * Version 1.0.1 〈2017/07/21〉
      - shebang 行を追加。

  * Version 1.0.0 〈2017/07/17〉
      - （jfmutil として）最初の公開版。
      - ZRTeXtor は v1.4.0 相当。

--------------------
Takayuki YATO (aka. "ZR")  
https://github.com/zr-tex8r
