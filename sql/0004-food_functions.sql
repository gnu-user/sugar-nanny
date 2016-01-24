CREATE FUNCTION get_food_item(_food_id INTEGER)
RETURNS JSONB
LANGUAGE SQL
AS
$$
    SELECT json_build_object('product_name', f.product_name,
          'carb', f.carbohydrates_100g,
          'sugar', f.sugars_100g,
          'fructose', f.fructose_100g,
          'sucrose', f.sucrose_100g,
          'glucose', f.glucose_100g,
          'fiber', f.fiber_100g,
          'sodium', f.sodium_100g,
          'protein', f.proteins_100g,
          'starch', f.starch_100g,
          'img_url', f.image_url,
          'img_small_url', f.image_small_url,
          'fat', f.fat_100g,
          'calories', round(f.energy_100g/4.184, 1))::JSONB
      FROM foods AS f
      WHERE food_id = _food_id;
$$;
