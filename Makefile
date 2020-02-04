IBBS = ibbs$(shell date +%m%y)
IBBS_URL = https://www.telnetbbsguide.com/bbslist/$(IBBS).zip
BBSDB = bbsdb.sqlite
TIMEOUT = 20
MAXC = 100

HTMLDOCS = \
	   html/index.html \
	   html/up.html \
	   html/down.html

all: $(HTMLDOCS)

clean:
	rm -f $(HTMLDOCS)

$(IBBS).zip:
	curl -o $@ $(IBBS_URL)

$(IBBS): $(IBBS).zip
	unzip -d $@ $<

$(IBBS)/syncterm.lst: $(IBBS)

.lastcheck: $(IBBS)/syncterm.lst
	ibbs check -i $(IBBS)/syncterm.lst -d $(BBSDB) \
		-t $(TIMEOUT) -m $(MAXC) && touch .lastcheck

html/up.html: .lastcheck
	ibbs render -s up -o $@

html/down.html: .lastcheck
	ibbs render -s down -o $@

html/index.html: .lastcheck
	ibbs render -o $@
