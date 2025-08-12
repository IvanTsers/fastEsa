# ---------- Helper scripts ----------
ORG2NW    := bash scripts/org2nw
PRETANGLE := awk -f scripts/preTangle.awk
PREWEAVE  := awk -f scripts/preWeave.awk

# ---------- C++ compilation configs ----------
CXXSTD   ?= -std=c++17
CXXWARN  ?= -Wall -Wextra
CXXOPT   ?= -O2
CXXFLAGS ?= $(CXXSTD) $(CXXWARN) $(CXXOPT)
INCLUDES := -Iphylonium -Iphylonium/src
#SYSLIBS  := -ldivsufsort64 -lstdc++ -lm

# ---------- Phylonium ----------
PHYL_REPO := https://github.com/kloetzl/phylonium.git

# We use only two objects from phylonium
PHYL_SRC  := phylonium/src/sequence.cxx phylonium/src/esa.cxx
PHYL_OBJS := build/sequence.o build/esa.o
LIB_PHYL  := libphylonium.a # a static lib assembled from the two objects

# ----------- A C-compatible wrapper for the C++ code ----------
W       := wrapper
W_ORG   := $(W).org # the LP implementation of the wrapper's files
W_CPP   := $(W).cpp # the wrapper itself
W_CPP_H := $(W).h # c++ header compatible with c
LIB_W   := lib$(W).a

# ---------- Targets ----------
# Default target
all: go-build

# ---------- Download phylonium and build its objects ----------
# Get the source code
phylonium:
	git clone $(PHYL_REPO)

# Generate config.h by autotools 
phylonium/config.h: phylonium
	cd phylonium && autoreconf -fi -Im4 && ./configure

# We compile phylonium's objects
build:
	mkdir -p build

build/%.o: phylonium/config.h | build
	g++ $(CXXFLAGS) $(INCLUDES) -c phylonium/src/$*.cxx -o build/$*.o

# We pack the objects of interest as a static phylonium lib
$(LIB_PHYL): $(PHYL_OBJS)
	ar rcs libphylonium.a $(PHYL_OBJS)

# ---------- Build a C wrapper for the C++ code ----------

# Extract the C++/C code from the literate program wrapper.org
$(W_CPP_H): $(W_ORG)
	$(PRETANGLE) $(W_ORG) | $(ORG2NW) | notangle -R$(W_CPP_H) > $(W_CPP_H)

$(W_CPP): $(W_ORG)
	$(PRETANGLE) $(W_ORG) | $(ORG2NW) | notangle -R$(W_CPP) > $(W_CPP)

# Compile the wrapper
build/wrapper.o: $(W_CPP) $(W_CPP_H) | build
	g++ $(CXXFLAGS) $(INCLUDES) -c $(W_CPP) -o wrapper.o

$(LIB_W): build/wrapper.o
	ar rcs $(LIB_W) wrapper.o


# ---------- Build the Go program ----------
go-build: $(LIB_PHYL) $(LIB_W) fastEsa.go
	go build fastEsa.go fastEsa

# Extract the Go code from the literate program wrapper.org

fastEsa.go: fastEsa.org
	$(PRETANGLE) fastEsa.org | $(ORG2NW) | notangle -RfastEsa.go | gofmt > fastEsa.go

doc:
	make -C doc

clean:
	rm -f fastEsa *.go *.cpp *.h *.o *.a
	rm -rf build phylonium
	make clean -C doc

init:
	go mod init fastEsa
	go mod tidy
