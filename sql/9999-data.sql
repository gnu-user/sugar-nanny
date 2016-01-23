-- TEST USERS
INSERT INTO users 
--	user_id, first_name, last_name, height, weight, sex, dob, email, password,
	    -- Diabetes specifics
--	diabetes_type, high_blood_pressure, pregnant, insulin_tdd, background_dose, pre_meal_target, post_meal_target, 
--   basil_corr_factor, bolus_corr_factor, grams_carb_per_unit)
VALUES
(
	1, 'Jonathan', 'Gillett', 1.9, 90.7, 'M', '1990-05-17', 'jonathan.gillett@uoit.net', 'test',
	1, FALSE, FALSE, 34, 2, 6.2, 8.9, 44.118, 52.94, 13.235
),
(
	2, 'Eric', 'Matthews', 1.7272, 70.3, 'M', '1993-01-24', 'matthew3@uwindsor.ca', 'test',
	1, FALSE, FALSE, 40, 2, 5.2, 7.9, 37.5, 45, 11.25
),
(
	3, 'Margaret', 'Askin', 1.6764, 72.2, 'F' , '1985-05-21', 'margaret@busybody.life', 'test',
	1, FALSE, FALSE, 44, 2, 5.9, 8.5, 34.09, 40.909, 10.227
),
(
	4, 'Donald', 'Skipman', 1.8288, 92.6, 'M' , '1972-11-06', 'donald@donaldskippy.me', 'test',
	2, FALSE, FALSE, 27, 2, 6.1, 9.2, 55.56, 66.67, 16.67
),
(
	5, 'Jennifer', 'Basketti', 1.7, 79.2, 'F' , '1983-12-27', 'basketti@basketcasejenny.me', 'test',
	1, FALSE, FALSE, 42, 2, 6.5, 9.6, 35.71, 42.857, 10.714
)
;
