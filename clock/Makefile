
ATSCC=$(ATSHOME)/bin/atscc
ATSOPT=$(ATSHOME)/bin/atsopt

ATSCCFLAGS=-O2

GTKFLAGS=`pkg-config gtk+-2.0 --cflags --libs`


SOURCES := \
  workshop2.sats \
  workshop2.dats \
  workshop2_job.sats \
  workshop2_job.dats \
  workshop2_tjob.dats \
  workshop2_jobstore_hp.dats \
  workshop2_jobstorelock.dats \

OBJECTS := $(SOURCES)
OBJECTS := $(patsubst %.sats, %_sats.o, $(OBJECTS))
OBJECTS := $(patsubst %.dats, %_dats.o, $(OBJECTS))

######

%_sats.o: %.sats ; $(ATSCC) $(ATSCCFLAGS) -c $<
%_dats.o: %.dats ; $(ATSCC) $(ATSCCFLAGS) -c $<

######

clock: gtkcairoclock.dats $(OBJECTS)
	$(ATSCC) -D_ATS_MULTITHREAD -o $@  $(GTKFLAGS) -lm -lpthread $< $(OBJECTS)


clean:: ; rm -f *~
clean:: ; rm -f *_?ats.o *_?ats.c
