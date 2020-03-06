# Generic make file for LaTeX: requires GNU make

TEXFILE = $(wildcard *.tex)

.PHONY: dvi pdf clean

pdf:	$(TEXFILE:.tex=.pdf)
# ps:	    $(TEXFILE:.tex=.ps)
dvi:	$(TEXFILE:.tex=.dvi)

%.pdf: %.tex
		( \
		\pdflatex $<; \
		while \grep -q "Rerun to get cross-references right." $(<:.tex=.log); \
		do \
				\pdflatex $<; \
		done \
		)

#%.ps: %.dvi
#		\dvips -q -t letter $<

#%.pdf: %.dvi
#		\dvipdf $<

clean:
		@\rm -f \
		$(TEXFILE:.tex=.aux) \
		$(TEXFILE:.tex=.log) \
		$(TEXFILE:.tex=.out) \
		$(TEXFILE:.tex=.dvi) \
		$(TEXFILE:.tex=.toc) \
		$(TEXFILE:.tex=.ps)

