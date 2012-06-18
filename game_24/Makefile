ATSCC=$(ATSHOME)/bin/atscc
ATSOPT=$(ATSHOME)/bin/atsopt

all:: test ; ./test

test: \
  workshop.sats \
  workshop.dats \
  workshop_job.dats \
  workshop_jobstore_hp.dats \
  GameOf24.sats \
  GameOf24.dats \
  ParGameOf24.sats \
  ParGameOf24.dats \
  test.dats
	atscc -D_ATS_MULTITHREAD -o test -lpthread $^
# end of [all]

clean:: ; rm -f *~
clean:: ; rm -f *_?ats.o *_?ats.c

