CREATE FUNCTION get_food_item(_food_id INTEGER)
RETURNS JSONB
LANGUAGE SQL
AS
$$
    SELECT json_build_object('product_name', f.product_name,
          'carb', COALESCE(f.carbohydrates_100g, 0.0),
          'sugar', COALESCE(f.sugars_100g, 0.0),
          'fructose', COALESCE(f.fructose_100g, 0.0),
          'sucrose', COALESCE(f.sucrose_100g, 0.0),
          'glucose', COALESCE(f.glucose_100g, 0.0),
          'fiber', COALESCE(f.fiber_100g, 0.0),
          'sodium', COALESCE(f.sodium_100g, 0.0),
          'protein', COALESCE(f.proteins_100g, 0.0),
          'starch', COALESCE(f.starch_100g, 0.0),
          'img_url', f.image_url,
          'img_small_url', f.image_small_url,
          'fat', COALESCE(f.fat_100g, 0.0),
          'calories', round(f.energy_100g/4.184, 1))::JSONB
      FROM foods AS f
      WHERE food_id = _food_id;
$$;


CREATE FUNCTION food_search(_query VARCHAR)
RETURNS JSONB
LANGUAGE SQL
AS
$$
    SELECT json_agg(json_build_object( (SELECT food_id, product_name
                                FROM foods
                                WHERE product_name LIKE '%' || lower(_query) || '%') );
                   )::JSONB AS response
$$;
