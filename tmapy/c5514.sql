
CREATE OR REPLACE FUNCTION c5514(geom GEOMETRY) RETURNS NUMERIC AS $$
BEGIN
  RETURN Round(((ST_X(ST_Transform(ST_Centroid(ST_Envelope(geom)), 4326)) - 24.83333333) / 1.34)::numeric, 1);
END;
$$ LANGUAGE plpgsql;
