# Відкритий посібник з відкритих даних

PANDOC= /usr/bin/pandoc
LESSC= /usr/bin/lessc

BASENAME= docs/opendatamanual

# source documents.md
CHAPTERS= 000_about.md\
					001_intro.md\
					010_sources.md\
					020_formats.md\
					030_getting.md\
					031_regex.md\
					032_optimize.md\
					040_statistics.md\
					050_visulization.md\
					060_maps.md\
					070_examples.md\
					080_distribute.md\
					900_appendixes.md
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
OUTDOCS= $(BASENAME).pdf $(BASENAME).epub $(BASENAME).html  $(BASENAME).docx $(BASENAME).odt

STYLE-EPUB= $(STYLEDIR)/$(BASENAME-S-EPUB).css
STYLE-HTML= $(STYLEDIR)/$(BASENAME-S-HTML).css

# COMMONFLAGS= --smart --standalone
COMMONFLAGS= --standalone

# спільні опції для HTML та електоркнижок
#  --section-divs довелося вимкнути, бо в нас не зовсім регулярна структура
MLFLAGS= --include-in-header=$(STYLEDIR)/comment.ht
# спільні опції для електрокнижок
EBOOKFLAGS= --highlight-style=monochrome --to epub3
EPUBFLAGS= $(MLFLAGS) $(EBOOKFLAGS)  --css=$(STYLE-EPUB) --template=style/epub.html
HTMLFLAGS= $(MLFLAGS)  -c $(STYLE-HTML) --to html5 --highlight-style=zenburn --self-contained --toc --metadata title="Посібник з відкритих даних"
FBFLAGS= --write=fb2
PDFLAGS=
DOCXFLAGS=
#--reference-docx=ref/DOCX.docx
ODTFLAGS= 
#--reference-odt=ref/ODT.odt

# збираємо тимчасовий файл, обробка m4 буде тут, а поки-що конкатенація
$(TEMPMD): $(CHAPTERS)
	cat $(CHAPTERS) > $@
# $(TEMPMD): $(CHAPTERS)
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

$(BASENAME).pdf: $(TEMPMD)
	$(PANDOC) $(COMMONFLAGS) $(PDFLAGS)  -o $@ $<

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
	rm -f  $(OUTDOCS) $(TEMPMD) $(STYLE-EPUB) $(STYLE-HTML)

.PHONY: all clean epub html docx odt
