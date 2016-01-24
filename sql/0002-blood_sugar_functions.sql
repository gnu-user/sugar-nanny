/* Diabetes equations:

High Blood Sugar Correction Dose = Difference between actual blood sugar and target blood sugar, divided by correction factor
HBS-CD = (ABS - TBS) / 0.0555 / CF
** ABS and TBS are in mg/dL for US measurements, so use division by 0.0555 to convert to mmol/L

Correction Factor (regular insulin)
CF = 1500 / TDI

Correction Factor (rapid-acting insulin) = 1800 / TDI
CF = 1800 / TDI

grams of carbs covered by 1 dose of insulin = 450 / total daily insulin dosage
g-CHO = 450 / TDI
*/
CREATE FUNCTION set_basal_correction_factor(_account_id INTEGER)
RETURNS NUMERIC
LANGUAGE SQL
AS
$$
	--How much insulin to use to counter-act X grams of carbs:
	UPDATE accounts
        SET basal_correction_factor = 1500.0 / insulin_tdd
    		WHERE account_id = _account_id;
$$;
CREATE FUNCTION set_bolus_correction_factor(_account_id INTEGER)
RETURNS NUMERIC
LANGUAGE SQL
AS
$$
	--How much insulin to use to counter-act X grams of carbs:
	UPDATE accounts
        SET bolus_correction_factor = 1800.0 / insulin_tdd
    		WHERE account_id = _account_id;
$$;
CREATE FUNCTION set_gram_(_account_id INTEGER)
RETURNS NUMERIC
LANGUAGE SQL
AS
$$
	--How much insulin to use to counter-act X grams of carbs:
	UPDATE accounts
        SET grams_carb_per_unit = 450.0 / insulin_tdd
    		WHERE account_id = _account_id;
$$;

CREATE FUNCTION food_insulin_units_required(_account_id INTEGER, _food_id INTEGER, _servings NUMERIC)
RETURNS NUMERIC
LANGUAGE SQL
AS
$$
	--How much insulin to use to counter-act X grams of carbs:
	SELECT (f.carbohydrates_100g / a.grams_carb_per_unit) * _servings
		FROM foods AS f, accounts as u
		WHERE a.account_id = _account_id
			AND f.food_id = _food_id;
$$;


-- TODO make comparison case-insensitive
CREATE FUNCTION food_insulin_units_required(_account_id INTEGER, _food_id INTEGER, _servings NUMERIC)
RETURNS NUMERIC
LANGUAGE SQL
AS
$$
	--How much insulin to use to counter-act X grams of carbs:
	SELECT (f.carbohydrates_100g / a.grams_carb_per_unit) * _servings
		FROM foods AS f, accounts as u
		WHERE a.account_id = _account_id
			AND f.food_id = _food_id;
$$;

CREATE FUNCTION account_sugar_to_target_basal(_account_id INTEGER, _actual_bs NUMERIC, _target_bs NUMERIC)
RETURNS NUMERIC
LANGUAGE SQL
AS
$$
	--How much insulin needed to get from high blood sugar to a target blood sugar:
	--0.0555 is a constant conversion factor from mg/dL to mmol/L
	SELECT (_actual_bs - _target_bs) / (a.basal_corr_factor * 0.0555)
		FROM accounts AS a
		WHERE a.account_id = _account_id;
$$;

CREATE FUNCTION account_sugar_to_target_bolus(_account_id INTEGER, _actual_bs NUMERIC, _target_bs NUMERIC)
RETURNS NUMERIC
LANGUAGE SQL
AS
$$
	--How much insulin needed to get from high blood sugar to a target blood sugar:
	--0.0555 is a constant conversion factor from mg/dL to mmol/L
	SELECT (_actual_bs - _target_bs) / (a.bolus_corr_factor * 0.0555)
		FROM accounts AS a
		WHERE a.account_id = _account_id;
$$;


CREATE FUNCTION account_current_to_target_basal(_account_id INTEGER, _target_bs NUMERIC)
RETURNS NUMERIC
LANGUAGE SQL
AS
$$
	--How much insulin needed to get from high blood sugar to a target blood sugar:
	(SELECT * FROM account_sugar_to_target_basal(_account_id,
			(SELECT r.reading FROM accounts AS a, readings AS r WHERE a.account_id = _account_id
				AND r.reading_timestamp =
					(SELECT max(reading_timestamp)
						FROM readings
						WHERE account_id = _account_id
						GROUP BY _account_id)
			),
			_target_bs
			)
	);
$$;

CREATE FUNCTION account_current_to_target_bolus(_account_id INTEGER, _target_bs NUMERIC)
RETURNS NUMERIC
LANGUAGE SQL
AS
$$
	--How much insulin needed to get from high blood sugar to a target blood sugar:
	(SELECT * FROM account_sugar_to_target_bolus(_account_id,
			(SELECT r.reading FROM accounts AS a, readings AS r WHERE a.account_id = _account_id
				AND r.reading_timestamp =
					(SELECT max(reading_timestamp)
						FROM readings
						WHERE account_id = _account_id
						GROUP BY _account_id)
			),
			_target_bs
		)
	);
$$;
