import random as r;
import matplotlib.pyplot as plt;
import time;
import datetime as dt;
import psycopg2 as pg;

points = [(420, 4.3),(480, 4.5),(525, 6.25),(570, 4.5),(600, 4.75),(630,5),(750, 4.4),(825, 6.15),(870, 4.75),(900, 5),(945, 5.25),(1080, 5),(1125, 6.25),(1155, 5.25),(1200, 5.75),(1260, 5.5),(1320, 5.25),(1380, 4.75),(60, 4.4)];

def genNewSet(p):
	shiftedPoints = [ (x + r.randrange(-15, 15), y + r.uniform(-0.4, 0.4)) for (x, y) in p ]	

	#combine points with a probability of 0.2
	rPoints = [];

	pointsIter = iter(range(0, len(shiftedPoints)));
	for i in pointsIter:
#		if r.random() < 0.2:
#			if i == len(shiftedPoints)-1:
#				break;

#			i2 = next(pointsIter);
#			rPoints.append( ((shiftedPoints[i][0]+shiftedPoints[i2][0])/2, (shiftedPoints[i][1]+shiftedPoints[i2][1])/2) );
#		else:
		rPoints.append( shiftedPoints[i] );

	rPoints[len(rPoints)-1] = (rPoints[len(rPoints)-1][0], rPoints[0][1]);

	return rPoints;

def getTimeFromMinutes(minutes):
	minStr = minutes % 60;
	if minStr < 10:
		minStr = "0" + str(minStr);
	else:
		minStr = str(minStr);

	return str(int(minutes/60)) + ":" + minStr;

#x, y = zip(*genNewSet(points));
#plt.plot(x, y, "ro", linestyle="-");
#plt.show();


for i in range(1,6):

	today = dt.date.today();
	date = today - dt.timedelta(days=31);

	oneDay = dt.timedelta(days=1);
	lastPoint = (0, r.uniform(3.33, 4.0));

	while date != today:
		p = genNewSet(points);

		p[0] = (p[0][0], r.uniform(3.33, lastPoint[1]));
		lastPoint = p[len(p) - 1];

		with pg.connect('dbname=sugarnanny') as conn:
			for point in p:
				info = (i, str(date) + " " + str(getTimeFromMinutes(point[0])) + ":00", 
					"{:.2f}".format(point[1]))
				print info;		
				with conn.cursor() as cur:
					cur.execute('''
						    INSERT INTO readings (user_id, reading_timestamp, reading)
						    VALUES (%s, %s, %s)
						   ''', info);

		date += oneDay;
