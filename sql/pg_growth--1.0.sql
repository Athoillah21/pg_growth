CREATE TABLE db_size_history (
    record_date DATE PRIMARY KEY,
    db_size BIGINT,
    db_size_pretty TEXT
);

CREATE TABLE db_size_history_hourly (
    record_time TIMESTAMP PRIMARY KEY,
    db_size BIGINT,
    db_size_pretty TEXT
);

CREATE OR REPLACE FUNCTION record_db_size() RETURNS VOID AS $$
DECLARE
    db_size BIGINT;
    db_size_pretty TEXT;
BEGIN
    SELECT pg_database_size(current_database()), pg_size_pretty(pg_database_size(current_database()))
    INTO db_size, db_size_pretty;
    INSERT INTO db_size_history (record_date, db_size, db_size_pretty)
    VALUES (CURRENT_DATE, db_size, db_size_pretty)
    ON CONFLICT (record_date) DO UPDATE
    SET db_size = EXCLUDED.db_size,
        db_size_pretty = EXCLUDED.db_size_pretty;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION record_db_size_hourly() RETURNS VOID AS $$
DECLARE
    db_size BIGINT;
    db_size_pretty TEXT;
BEGIN
    SELECT pg_database_size(current_database()), pg_size_pretty(pg_database_size(current_database()))
    INTO db_size, db_size_pretty;
    INSERT INTO db_size_history_hourly (record_time, db_size, db_size_pretty)
    VALUES (CURRENT_TIMESTAMP, db_size, db_size_pretty)
    ON CONFLICT (record_time) DO UPDATE
    SET db_size = EXCLUDED.db_size,
        db_size_pretty = EXCLUDED.db_size_pretty;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_growth_daily()
RETURNS TABLE (
    record_date DATE,
    db_size_pretty TEXT,
    growth_bytes BIGINT,
    growth_pretty TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT record_date, db_size_pretty,
       db_size - LAG(db_size) OVER (ORDER BY record_date) AS growth_bytes,
       pg_size_pretty(db_size - LAG(db_size) OVER (ORDER BY record_date)) AS growth_pretty
    FROM db_size_history
    ORDER BY record_date;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_growth_hourly()
RETURNS TABLE (
    record_time TIMESTAMP,
    db_size_pretty TEXT,
    growth_bytes BIGINT,
    growth_pretty TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT h.record_time, h.db_size_pretty,
           h.db_size - LAG(h.db_size) OVER (ORDER BY h.record_time) AS growth_bytes,
           pg_size_pretty(h.db_size - LAG(h.db_size) OVER (ORDER BY h.record_time)) AS growth_pretty
    FROM db_size_history_hourly h
    ORDER BY h.record_time;
END;
$$ LANGUAGE plpgsql;

SELECT cron.schedule('daily_db_size', '0 0 * * *', 'SELECT record_db_size();');
SELECT cron.schedule('hourly_db_size', '0 * * * *', 'SELECT record_db_size_hourly();');

