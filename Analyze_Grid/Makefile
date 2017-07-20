ANALYZERDIR=Blah
SRCDIR = src
BTAGDIR = $(SRCDIR)/btagging
OBJDIR = obj
EXE = $(ANALYZERDIR)/Analyzer


#------------------------------------------------------------------------------
SOURCES = $(wildcard $(ANALYZERDIR)/$(SRCDIR)/*.cc)
SOURCES = $(wildcard $(ANALYZERDIR)/$(SRCDIR)/*.h)
OBJECTS = $(SOURCES:$(ANALYZERDIR)/$(SRCDIR)/%.cc=$(ANALYZERDIR)/$(OBJDIR)/%.o)

BTAGSRC = $(wildcard $(ANALYZERDIR)/$(BTAGDIR)/*.cpp)
BTAGOBJ = $(BTAGSRC:$(ANALYZERDIR)/$(BTAGDIR)/%.cpp=$(ANALYZERDIR)/$(OBJDIR)/%.o)

#------------------------------------------------------------------------------

all: .dummy

.dummy: $(EXE) $(OBJECTS) $(BTAGOBJ) $(SOURCES) $(BTAGSRC) $(HFILES)
	touch .dummy
	mkdir $$(date +%y-%m-%d_%H:%M)
	cp $(EXE) $$(date +%y-%m-%d_%H:%M)
	cp -r$(ANALYZERDIR)/$(SRCDIR) $$(date +%y-%m-%d_%H:%M)
	cp -r$(ANALYZERDIR)/ $$(date +%y-%m-%d_%H:%M)	


