CREATE FUNCTION account_signup(_first_name TEXT, _last_name TEXT, 
                               _height NUMERIC, _weight NUMERIC,
                               _sex CHAR(1), _dob DATE,
                               _email TEXT, _password TEXT,
                               _diabetes_type INTEGER,
                               _high_blood_pressure BOOLEAN,
                               _pregnant BOOLEAN,
                               _insulin_tdd INTEGER,
                               _background_dose INTEGER,
                               _pre_meal_target NUMERIC,
                               _post_meal_target NUMERIC)
RETURNS JSONB
LANGUAGE PLPGSQL
AS
$$
DECLARE
  _response JSONB;
  _account_id INTEGER;
BEGIN
  IF EXISTS (SELECT 1 FROM accounts WHERE email = lower(_email)) THEN
    SELECT json_build_object('success', FALSE,
                             'status', 'email_exists',
                             'message', 'An account with that email already exists.')::JSONB
           INTO _response;
    RETURN _response;
  END IF;
  INSERT INTO accounts (first_name, last_name, 
                        height, weight,
                        sex, dob,
                        email, password,
                        diabetes_type,
                        high_blood_pressure,
                        pregnant,
                        insulin_tdd,
                        background_dose,
                        pre_meal_target,
                        post_meal_target)
  VALUES (_first_name, _last_name, 
          _height, _weight,
          _sex, _dob,
          _email, _password,
          _diabetes_type,
          _high_blood_pressure,
          _pregnant,
          _insulin_tdd,
          _background_dose,
          _pre_meal_target,
          _post_meal_target)
  RETURNING account_id INTO _account_id;
  UPDATE accounts
  SET basal_corr_factor = (SELECT set_basal_correction_factor(_insulin_tdd)),
      bolus_corr_factor = (SELECT set_bolus_correction_factor(_insulin_tdd)),
      grams_carb_per_unit = (SELECT set_grams_of_carb_per_unit(_insulin_tdd))
  WHERE account_id = _account_id;
  SELECT json_build_object('success', TRUE,
                           'status', 'success',
                           'message', 'Account created successfully.',
                           'account_id', _account_id)::JSONB
         INTO _response;
  RETURN _response;
END;
$$;