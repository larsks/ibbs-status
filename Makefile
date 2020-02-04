IBBS = ibbs$(shell date +%m%y)
IBBS_URL = https://www.telnetbbsguide.com/bbslist/$(IBBS).zip
BBSDB = bbsdb.sqlite
TIMEOUT = 20
MAXC = 100

HTMLDOCS = \
	   html/index.html \
	   html/up/index.html \
	   html/down/index.html \
	   html/syncterm.lst \
	   html/up/syncterm.lst \
	   html/down/syncterm.lst \
	   html/etherterm.xml \
	   html/up/etherterm.xml \
	   html/down/etherterm.xml \
	   html/qodem.ini \
	   html/up/qodem.ini \
	   html/down/qodem.ini \
	   html/magiterm.ini \
	   html/up/magiterm.ini \
	   html/down/magiterm.ini

RENDER = ibbs render -p generated_at="$(shell TZ=UTC date "+%Y-%m-%d %T")"

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

html/up:
	mkdir -p html/up

html/down:
	mkdir -p html/down

html/up/index.html: html/up .lastcheck
	$(RENDER) -p active=up -s up -o $@

html/down/index.html: html/down .lastcheck
	$(RENDER) -p active=down -s down -o $@

html/index.html: .lastcheck
	$(RENDER) -p active=all -o $@

html/syncterm.lst: .lastcheck
	ibbs export -o $@ -f syncterm

html/up/syncterm.lst: .lastcheck
	ibbs export -o $@ -f syncterm -s up

html/down/syncterm.lst: .lastcheck
	ibbs export -o $@ -f syncterm -s down

html/magiterm.ini: .lastcheck
	ibbs export -o $@ -f magiterm

html/up/magiterm.ini: .lastcheck
	ibbs export -o $@ -f magiterm -s up

html/down/magiterm.ini: .lastcheck
	ibbs export -o $@ -f magiterm -s down

html/qodem.ini: .lastcheck
	ibbs export -o $@ -f qodem

html/up/qodem.ini: .lastcheck
	ibbs export -o $@ -f qodem -s up

html/down/qodem.ini: .lastcheck
	ibbs export -o $@ -f qodem -s down

html/etherterm.xml: .lastcheck
	ibbs export -o $@ -f etherterm

html/up/etherterm.xml: .lastcheck
	ibbs export -o $@ -f etherterm -s up

html/down/etherterm.xml: .lastcheck
	ibbs export -o $@ -f etherterm -s down
