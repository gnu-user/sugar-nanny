CREATE FUNCTION summarize_readings(_reading readings)
RETURNS JSONB
LANGUAGE SQL
AS
$$
SELECT json_build_object('timestamp', $1.reading_timestamp::TIMESTAMP WITHOUT TIME ZONE,
                         'reading', $1.reading)::JSONB;
$$;


CREATE FUNCTION summarize_doses(_dose doses)
RETURNS JSONB
LANGUAGE SQL
AS
$$
SELECT json_build_object('timestamp', $1.dose_timestamp::TIMESTAMP WITHOUT TIME ZONE,
                         'dose_units', $1.dose_units)::JSONB;
$$;

CREATE FUNCTION summarize_food_history(_food_history food_history)
RETURNS JSONB
LANGUAGE SQL
AS
$$
SELECT 
      json_build_object('timestamp', $1.food_timestamp::TIMESTAMP WITHOUT TIME ZONE,
                        'servings', $1.food_servings,
                        'calories', round(energy_100g / 4.184, 2),
                        'fat', fat_100g,
                        'cholesterol', cholesterol_100g,
                        'sodium', sodium_100g,
                        'carbs', carbohydrates_100g,
                        'fibre', fiber_100g,
                        'sugar', sugars_100g,
                        'protein', proteins_100g)::JSONB
FROM
      foods
WHERE food_id = $1.food_id
$$;