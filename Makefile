# Відкритий посібник з відкритих даних


PANDOC= /usr/bin/pandoc
LESSC= /usr/bin/lessc

BASENAME= docs/відкритий-посібник-з-відкритих-даних

# source documents.md
CHAPTERS= про.md\
          вступ.md\
          джерела.md\
          формати.md\
          отримання.md\
          регулярні-вирази.md\
          оптимізація-структури.md\
          статистика.md\
          візуалізація.md\
          мапи.md\
          індекси.md\
          епілог.md\
          додатки.md
STYLESLESS= $(STYLEDIR)/main.less \
             $(STYLEDIR)/typography.less\
             $(STYLEDIR)/use.less\
             $(STYLEDIR)/normalize.less
BASENAME-S-EPUB= epub
BASENAME-S-HTML= html

OUTDIR= docs
STYLEDIR= style
TEMPMD= do-not-edit-me.markdown

# output documents
# $(BASENAME).fb2 $(BASENAME).pdf $(BASENAME).docx $(BASENAME).odt
OUTDOCS= $(BASENAME).epub $(BASENAME).html  $(BASENAME).docx $(BASENAME).odt

STYLE-EPUB= $(STYLEDIR)/$(BASENAME-S-EPUB).css
STYLE-HTML= $(STYLEDIR)/$(BASENAME-S-HTML).css

COMMONFLAGS= --smart --standalone
# спільні опції для HTML та електоркнижок
#  --section-divs довелося вимкнути, бо в нас не зовсім регулярна структура
MLFLAGS= --include-in-header=$(STYLEDIR)/comment.ht
# спільні опції для електрокнижок
EBOOKFLAGS= --highlight-style=monochrome
EPUBFLAGS= $(MLFLAGS) $(EBOOKFLAGS)  --epub-stylesheet=$(STYLE-EPUB) --template=style/epub.html
HTMLFLAGS= $(MLFLAGS)  -c $(STYLE-HTML) --highlight-style=zenburn --self-contained --toc
FBFLAGS= --write=fb2
PDFLAGS=
DOCXFLAGS=
#--reference-docx=ref/DOCX.docx
ODTFLAGS= 
#--reference-odt=ref/ODT.odt

# збираємо тимчасовий файл, обробка m4 буде тут, а поки-що конкатенація
$(TEMPMD): $(CHAPTERS)
	cat $(CHAPTERS) > $@
#$(TEMPMD): $(CHAPTERS)
#	cat $(CHAPTERS) > deleteme
#	m4 deleteme  > $@
#	rm deleteme

$(STYLE-EPUB):
	lessc $(STYLEDIR)/$(BASENAME-S-EPUB).less > $(STYLE-EPUB)
$(STYLE-HTML):
	lessc $(STYLEDIR)/$(BASENAME-S-HTML).less > $(STYLE-HTML)

$(BASENAME).epub: $(TEMPMD) $(STYLE-EPUB)
	$(PANDOC) $(COMMONFLAGS) $(EPUBFLAGS)  -o $@ metadata.yaml $<

$(BASENAME).html: $(TEMPMD) $(STYLE-HTML)
	$(PANDOC) $(COMMONFLAGS) $(HTMLFLAGS)  -o $@ $<

#$(BASENAME).fb2: $(TEMPMD)
#	$(PANDOC) $(COMMONFLAGS) $(FBFLAGS)  -o $@ $<

#$(BASENAME).pdf: $(TEMPMD)
#	$(PANDOC) $(COMMONFLAGS) $(PDFLAGS)  -o $@ $<

$(BASENAME).docx: $(TEMPMD)
	$(PANDOC) $(COMMONFLAGS) $(DOCXFLAGS)  -o $@ $<

$(BASENAME).odt:  $(TEMPMD)
	$(PANDOC) $(COMMONFLAGS) $(ODTFLAGS)  -o $@ $<

all: $(OUTDOCS)
epub: $(BASENAME).epub
html: $(BASENAME).html
docx: $(BASENAME).docx
odt: $(BASENAME).odt

clean:
	rm -f  $(OUTDOCS) $() $(TEMPMD) $(STYLE-EPUB) $(STYLE-HTML)

#$(BASENAME).fb2 # $(BASENAME).pdf $(BASENAME).docx $(BASENAME).odt

.PHONY: all clean epub html docx odt
