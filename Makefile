EXTENSION = pg_growth
DATA = sql/pg_growth--1.0.sql

# Ensure PG_CONFIG is set, which is needed to find pgxs
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

install:
	mkdir -p $(DESTDIR)$(datadir)/extension
	install -m 644 pg_growth.control $(DESTDIR)$(datadir)/extension/
	install -m 644 sql/pg_growth--1.0.sql $(DESTDIR)$(datadir)/extension/

