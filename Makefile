IBBS = ibbs$(shell date +%m%d%y)
IBBS_URL = https://www.telnetbbsguide.com/bbslist/$(IBBS).zip
BBSDB = ../ibbs-database/bbsdb.sqlite
TIMEOUT = 10
MAXC = 200

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
	   html/down/magiterm.ini \
	   html/history.html

TEMPLATE_PATH = ./templates
RENDER = ibbs render \
	 -d $(BBSDB) \
	 -p generated_at="$(shell TZ=UTC date "+%Y-%m-%d %T")"

all: $(HTMLDOCS)

clean:
	rm -f $(HTMLDOCS)

$(IBBS).zip:
	curl -o $@ $(IBBS_URL)

data data/syncterm.lst: $(IBBS).zip
	rm -rf data
	unzip -d data $<
	touch data/syncterm.lst

.lastimport: data/syncterm.lst
	ibbs -v import -i $< -d $(BBSDB) && touch .lastimport

.lastcheck: .lastimport
	ibbs -v check -d $(BBSDB) -t $(TIMEOUT) -m $(MAXC) && touch .lastcheck

html/up:
	mkdir -p html/up

html/down:
	mkdir -p html/down

html/history.html: .lastcheck
	$(RENDER) -o $@ -p active=history templates/history.html

html/up/index.html: html/up .lastcheck
	$(RENDER) -p active=up -s up -o $@ templates/bbslist.html

html/down/index.html: html/down .lastcheck
	$(RENDER) -p active=down -s down -o $@ templates/bbslist.html

html/index.html: .lastcheck
	$(RENDER) -p active=all -o $@ templates/bbslist.html

html/syncterm.lst: .lastcheck
	ibbs export -d $(BBSDB) -o $@ -f syncterm

html/up/syncterm.lst: .lastcheck
	ibbs export -d $(BBSDB) -o $@ -f syncterm -s up

html/down/syncterm.lst: .lastcheck
	ibbs export -d $(BBSDB) -o $@ -f syncterm -s down

html/magiterm.ini: .lastcheck
	ibbs export -d $(BBSDB) -o $@ -f magiterm

html/up/magiterm.ini: .lastcheck
	ibbs export -d $(BBSDB) -o $@ -f magiterm -s up

html/down/magiterm.ini: .lastcheck
	ibbs export -d $(BBSDB) -o $@ -f magiterm -s down

html/qodem.ini: .lastcheck
	ibbs export -d $(BBSDB) -o $@ -f qodem

html/up/qodem.ini: .lastcheck
	ibbs export -d $(BBSDB) -o $@ -f qodem -s up

html/down/qodem.ini: .lastcheck
	ibbs export -d $(BBSDB) -o $@ -f qodem -s down

html/etherterm.xml: .lastcheck
	ibbs export -d $(BBSDB) -o $@ -f etherterm

html/up/etherterm.xml: .lastcheck
	ibbs export -d $(BBSDB) -o $@ -f etherterm -s up

html/down/etherterm.xml: .lastcheck
	ibbs export -d $(BBSDB) -o $@ -f etherterm -s down
