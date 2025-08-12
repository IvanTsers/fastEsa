NAME := fastEsa

# ---------- Helper scripts ----------
ORG2NW    := bash ../scripts/org2nw
PRETANGLE := awk -f ../scripts/preTangle.awk
PREWEAVE  := awk -f ../scripts/preWeave.awk

date = $(shell git log | grep -m 1 Date | sed -r 's/Date: +[A-Z][a-z]+ ([A-Z][a-z]+) ([0-9]+) [^ ]+ ([0-9]+) .+/\2_\1_\3/')
version = $(shell git describe)

all: wrapper.tex $(NAME).tex $(NAME)Doc.pdf

# Weave the wrapper's doc
wrapper.tex: ../wrapper.org
	$(ORG2NW) ../wrapper.org | $(PREWEAVE) | noweave -n -x > wrapper.tex

# Weave the fastEsa's doc
$(NAME).tex: ../$(NAME).org
	$(ORG2NW) ../fastEsa.org | $(PREWEAVE) | noweave -n -x > $(NAME).tex

# Weave the main doc file
	echo $(date) | tr '_' ' ' > date.txt
	echo $(version) | tr '-' ' ' | awk '{printf "%s", $$1; if ($$2) printf "-%s", $$2; printf n}' > version.txt
	latex $(NAME)Doc
	bibtex $(NAME)Doc
	latex $(NAME)Doc
	latex $(NAME)Doc
	dvipdf -dALLOWPSTRANSPARENCY $(NAME)Doc
$(NAME)Doc.pdf: $(NAME)Doc.tex $(NAME).tex #$(NAME)_test.tex

# Weave the test's doc
#$(NAME)_test.tex: ../$(NAME)_test.org
#	bash ../scripts/org2nw ../$(NAME)_test.org  | awk -f ../scripts/preWeave.awk | noweav#e -n -x | sed 's/_test/\\_test/' > $(NAME)_test.tex
#
clean:
	rm -f wrapper.tex $(NAME).tex $(NAME)_test.tex *.pdf *.aux *.bbl *.blg *.dvi *.log *.toc date.txt version.txt
