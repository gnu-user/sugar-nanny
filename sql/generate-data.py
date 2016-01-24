import random as r
import datetime as dt
import psycopg2 as pg
import sys

points = [(420, 4.3), (480, 4.5), (525, 6.25), (570, 4.5), (600, 4.75), (630, 5),
          (750, 4.4), (825, 6.15), (870, 4.75), (900, 5), (945, 5.25), (1080, 5),
          (1125, 6.25), (1155, 5.25), (1200, 5.75), (1260, 5.5), (1320, 5.25),
          (1380, 4.75), (60, 4.4)]

if sys.argv == 4:
    db_info = {"database": "sugarnanny",
               "user": sys.argv[1],
               "password": sys.argv[2],
               "host": sys.argv[3]}
else:
    db_info = {"database": "sugarnanny"}


def gen_new_set(p):
    shifted_points = [(x + r.randrange(-15, 15), y + r.uniform(-0.4, 0.4)) for (x, y) in p]

    #combine points with a probability of 0.2
    r_points = []

    points_iter = iter(range(0, len(shifted_points)))
    for i in points_iter:
        r_points.append(shifted_points[i])

    r_points[len(r_points)-1] = (r_points[len(r_points)-1][0], r_points[0][1])

    return r_points


def get_time_from_minutes(minutes):
    min_str = minutes % 60
    if min_str < 10:
        min_str = "0" + str(min_str)
    else:
        min_str = str(min_str)

    return str(int(minutes/60)) + ":" + min_str


for i in range(1, 6):
    today = dt.date.today()
    date = today - dt.timedelta(days=31)

    one_day = dt.timedelta(days=1)
    last_point = (0, r.uniform(3.33, 4.0))

    while date != today:
        p = gen_new_set(points)

        p[0] = (p[0][0], r.uniform(3.33, last_point[1]))
        last_point = p[len(p) - 1]

        with pg.connect(**db_info) as conn:
            for point in p:
                info = (i, str(date) + " " + str(get_time_from_minutes(point[0])) + ":00",
                        "{:.2f}".format(point[1]))

                with conn.cursor() as cur:
                    cur.execute('''
                            INSERT INTO readings (account_id, reading_timestamp, reading)
                            VALUES (%s, %s, %s)
                           ''', info)
        date += one_day
