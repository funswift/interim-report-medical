#!/bin/sh

# グループ報告書
FILE	=report
# 個人報告書
ABST	=abst
# 分割され、インクルードされているファイル
SRC	=#chap1.tex chap2.tex,..., chap<n>.tex
#スタイルファイルやクラスファイルなど
OHTERS	=funpro.sty funpro.dvi funpro.dtx funpro.ins url.sty \
	okumacro.sty jsbook.cls nkf.c config.h utf8tbl.c
# 画像などのバイナリファイル
IMG	=#hoge.eps capture1.jpg
#文献データベース
REF	=#biblio.bib
#スタイルファイル
STY	=funpro
#クラスファイル
CLS	=jsbook.cls

# GNU Linux の場合
#DVIPS	=dvips -Ppdf 
#XDVI	=xdvik
# Red Hatの場合
#DVIPS	=pdvips -Ppdf
#XDVI	=pxdvi
# Windows+Cygwin+角藤pTeXの場合
DVIPS	=dvipsk -Ppdf -t a4
XDVI	=dviout 

# dvipdfmは非常に古いのでdvipdfmxを使うようにしてください。
DVIPDF	=dvipdfm
REFGREP	=grep "^LaTeX Warning: Label(s) may have changed."
# cc使っている人いるでしょうか
CC	=gcc
CFLAGS	=-O
TEX	=platex
RM	=rm -f
RMR	=rm -fr

all:	nkf $(STY).sty $(STY).pdf $(FILE).pdf #$(ABST).pdf

#スタイルファイル用の依存関係
$(STY).sty:	$(STY).dtx $(STY).ins
	$(TEX) $(STY).ins
$(STY).pdf:	$(STY).dvi
	$(DVIPDF) $(STY)
$(STY).ps:	$(STY).dvi
	$(DVIPS)  $(STY)
$(STY).dvi:	$(STY).dtx
	$(TEX) $(STY).dtx && $(TEX) $(STY).dtx
	$(RM) $(STY).aux $(STY).idx $(STY).ilg $(STY).ind $(STY).log

#グループ報告書用の依存関係
$(FILE).pdf: $(FILE).dvi
	$(DVIPDF) -o $(FILE).pdf $(FILE)
$(FILE).ps: $(FILE).dvi
	$(DVIPS) -o $(FILE).ps $(FILE)
$(FILE).dvi: $(FILE).aux $(FILE).toc
#文献データベースもちならば
#$(FILE).dvi: $(FILE).bbl $(FILE).aux
	$(TEX) $(FILE) 
	(while $(REFGREP) $(FILE).log; do $(TEX) $(FILE); done)
$(FILE).bbl: $(FILE).aux $(REFFILE) 
	$(BIBTEX) $(FILE)
$(FILE).toc: $(FILE).aux
	$(TEX) $(FILE)
$(FILE).aux: $(FILE).tex
	$(TEX) $(FILE)

#個人報告書の依存関係
$(ABST).pdf: $(ABST).dvi
	$(DVIPDF) -o $(ABST).pdf $(ABST)
$(ABST).ps: $(ABST).dvi
	$(DVIPS) -o $(ABST).ps $(ABST)
$(ABST).dvi: $(ABST).aux 
	$(TEX) $(ABST) 
	(while $(REFGREP) $(ABST).log; do $(TEX) $(ABST); done)
$(ABST).aux: $(ABST).tex
	$(TEX) $(ABST)
#掃除用
clean:
	$(RM) $(FILE).aux $(FILE).log $(FILE).toc $(FILE).lof $(FILE).lot
	$(RM) $(ABST).aux $(ABST).log utf8tbl.o *~

#アーカイブ作成用
tar:	$(SRC) $(REF) $(FILE).tex Makefile $(FILE).pdf $(STY).pdf \
	$(FILE).ps $(STY).ps
	mkdir -p $(FILE)src
	cp $(SRC) $(OHTERS) $(REF) $(IMG) $(FILE).tex Makefile  \
	$(FILE).pdf $(STY).pdf $(FILE).ps $(STY).ps $(FILE)src/
	zip -r $(FILE)src.zip $(FILE)src/
	$(RMR) $(FILE)src/
unzip:
	unzip -o $(FILE)src.zip

NKFE=./nkf -e -Lu
NKFS=./nkf -s -Lw
nkf:	nkf.c config.h utf8tbl.o
	$(CC) $(CFLAGS) -o nkf nkf.c utf8tbl.o
utf8tbl.o:	utf8tbl.c config.h
	$(CC) $(CFLAGS) -c utf8tbl.c

euc:	nkf
	$(NKFE) <$(STY).dtx >$(STY).dtx.e && mv $(STY).dtx.e $(STY).dtx
	$(NKFE) <$(STY).sty >$(STY).sty.e && mv $(STY).sty.e $(STY).sty
	$(NKFE) <$(CLS) >$(CLS).e && mv $(CLS).e $(CLS)
	$(NKFE) <$(FILE).tex >$(FILE).tex.e && mv $(FILE).tex.e $(FILE).tex
	$(NKFE) <$(ABST).tex >$(ABST).tex.e && mv $(ABST).tex.e $(ABST).tex
sjis:	nkf
	$(NKFS) <$(STY).dtx >$(STY).dtx.s && mv $(STY).dtx.s $(STY).dtx
	$(NKFS) <$(STY).sty >$(STY).sty.s && mv $(STY).sty.s $(STY).sty
	$(NKFS) <$(CLS) >$(CLS).s && mv $(CLS).s $(CLS)
	$(NKFS) <$(FILE).tex >$(FILE).tex.s && mv $(FILE).tex.s $(FILE).tex
	$(NKFS) <$(ABST).tex >$(ABST).tex.s && mv $(ABST).tex.s $(ABST).tex
