-- single route trip search
-- find all routes that stop at the specified depart station and then at the specified
-- destination station on a specific day of the week.
-- must account for available seats
-- must be able to order in multiple ways

-- in this example, we will find routes that stop at station 2 and stop at station 4
-- on tuesdays

-- get route id from route_include where station_id == input and isStop is true

CREATE VIEW rt_stA AS
    SELECT *
    FROM RouteInclude
    WHERE station_id = '2' AND stop = 'true';

CREATE VIEW rt_stB AS
    SELECT *
    FROM RouteInclude
    WHERE station_id = '4' AND stop = 'true';

SELECT * from rt_stB;

CREATE VIEW twoStopMatch AS
    SELECT rt_stA.route_id AS routeID, rt_stA.station_id AS stationA, rt_stB.station_id AS stationB  from rt_stA
    INNER JOIN rt_stB ON rt_stA.route_id = rt_stB.route_id;

SELECT * from twoStopMatch;

DROP VIEW stopDayMatch;

-- kept trainID in the following view because it will be necessary to utilize when customers are
-- added and train tickets begin to be issued.
CREATE VIEW stopDayMatch AS
    SELECT twoStopMatch.routeID AS routeID, stationa, stationb, day, train_id FROM twoStopMatch
    INNER JOIN Route_Schedules ON twoStopMatch.routeID = Route_Schedules.routeid
    AND day = 'Tuesday';

-- the following returns all of the routes that stop at station a and station b on the given day
SELECT * from stopDayMatch;

-- combination route trip search
-- all route combinations that stop at the specified depart station and destination station
-- on a specific day of the week
-- must account for available seats
-- must be able to order in multiple ways

-- in this example, we must find all routes that stop at a and all routes that stop at b
-- then we must find the stops in which these two routes overlap
-- using station 2 and 4 on 'Tuesday'

CREATE VIEW rt_stA_combo AS
    SELECT *
    FROM RouteInclude
    WHERE station_id = '2' AND stop = 'true'; --example input

CREATE VIEW rt_stB_combo AS
    SELECT *
    FROM RouteInclude
    WHERE station_id = '4' AND stop = 'true'; --example input

SELECT * FROM RouteInclude; -- reference
SELECT * FROM rt_stA_combo; -- includes all lines that stop at station "A"
SELECT * FROM rt_stB_combo; -- includes all lines that stop at station "B"

CREATE VIEW rtA_combo AS
    SELECT RouteInclude.route_id AS routeID, RouteInclude.station_id AS station, RouteInclude.stop AS stop
    FROM RouteInclude
    INNER JOIN rt_stA_combo ON rt_stA_combo.route_id = RouteInclude.route_id
    AND RouteInclude.stop = 'true'; -- if the route only passes through the station, we cannot use it as a layover

CREATE VIEW rtB_combo AS
    SELECT RouteInclude.route_id AS routeID, RouteInclude.station_id AS station, RouteInclude.stop AS stop
    FROM RouteInclude
    INNER JOIN rt_stB_combo ON rt_stB_combo.route_id = RouteInclude.route_id
    AND RouteInclude.stop = 'true'; -- if the route only passes through the station, we cannot use it as a layover

SELECT * FROM rtA_combo; -- includes every stop from routes that stop at station A
SELECT * FROM rtB_combo; -- includes every stop from routes that stop at station B

--find all routes that stop at station AB on Tuesday
DROP VIEW day_StationA_combo;
CREATE VIEW day_StationA_combo AS
    SELECT rtA_combo.routeID AS route, station, day, time, train_id
    FROM rtA_combo
    INNER JOIN Route_Schedules ON rtA_combo.routeID = Route_Schedules.routeid
    AND Route_Schedules.day = 'Tuesday';

DROP VIEW day_StationB_combo;
CREATE VIEW day_StationB_combo AS
    SELECT rtB_combo.routeID AS route, station, day, time, train_id
    FROM rtB_combo
    INNER JOIN Route_Schedules ON rtB_combo.routeID = Route_Schedules.routeid
    AND Route_Schedules.day = 'Tuesday';

SELECT * FROM day_StationA_combo; --contains only the routes that stop at station a on tuesday
SELECT * FROM day_StationB_combo; --contains only the routes that stop at station b on tuesday

DROP VIEW comboMatch;
CREATE VIEW comboMatch AS
    SELECT day_StationA_combo.route AS routeA, day_StationB_combo.route AS routeB, day_StationA_combo.station AS layover_station
    FROM day_StationA_combo
    INNER JOIN day_StationB_combo ON day_StationA_combo.station = day_StationB_combo.station
    AND day_StationA_combo.route != day_StationB_combo.route; --removes single route trips

-- routea stops at station a and the layover_station
-- routeb stops at the layover_station and station b
SELECT * FROM comboMatch;

-- need to add seat functionality after customers are added and tickets are issued

-- need to add sorting functionalities


-- advanced search a
-- find all TRAINS that pass through a specific station at a specific day/time combination


-- advanced search b
-- find the routes that travel more than one railline

-- advanced search c
-- rank the trains that are scheduled for more than one route

-- advanced search d
-- find the routes that pass through the same stations but dont have the same stops

-- advanced search e
-- find any stations through which all trains pass through

-- advanced search f
-- find all trains that do not stop at a specific station

-- advanced search g
-- find routes where they stop at least xx% (where xx is a number from 10-90) of the
-- stations from which they pass (eg route passing through 10 stops will stop at 5 will
-- be returned as a result of a 50% search

-- display the schedule of a route
-- for a specific route, list the days of departure, departure hours and trains that run it

-- advanced search i
-- find the availability of a route at every stop on a specific day and time
