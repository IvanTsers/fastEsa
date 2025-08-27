NAME := fastEsa

# ---------- Helper scripts ----------
ORG2NW    := bash ../scripts/org2nw
PREWEAVE  := awk -f ../scripts/preWeave.awk

# Build the version string
TAG = $(shell git tag -l | sort -V | tail -n1)
VERSION = $(shell git log --pretty=format:"%cs, ${TAG}-%h" -n 1)

# to force existing docs to re-compile, we pretend that targets are not files
.PHONY: wrapper.tex $(NAME).tex $(NAME)Doc.pdf
all: wrapper.tex $(NAME).tex $(NAME)Doc.pdf

# Weave the wrapper's doc
wrapper.tex: ../wrapper.org
	$(ORG2NW) ../wrapper.org | $(PREWEAVE) | noweave -n -x > wrapper.tex

# Weave the fastEsa's doc
$(NAME).tex: ../$(NAME).org
	$(ORG2NW) ../fastEsa.org | $(PREWEAVE) | noweave -n -x > $(NAME).tex

# Weave the main doc file
	echo $(VERSION) > version.txt
	latex $(NAME)Doc
	bibtex $(NAME)Doc
	latex $(NAME)Doc
	latex $(NAME)Doc
	dvipdf -dALLOWPSTRANSPARENCY $(NAME)Doc

$(NAME)Doc.pdf: $(NAME)Doc.tex $(NAME).tex

clean:
	rm -f wrapper.tex $(NAME).tex $(NAME)_test.tex *.pdf *.aux *.bbl *.blg *.dvi *.log *.toc date.txt version.txt
