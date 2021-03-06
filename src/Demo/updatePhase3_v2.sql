--
-- Combination View:
-- The following statements are generated by java program when 'Search"
-- is selected:
--
-- CREATE OR REPLACE VIEW rt_stA_combo AS
--    SELECT *
--    FROM RouteInclude
--    WHERE station_id = '2' AND stop = 'true'; --example input

-- CREATE OR REPLACE VIEW rt_stB_combo AS
--    SELECT *
--    FROM RouteInclude
--    WHERE station_id = '4' AND stop = 'true'; --example input

-- For testing:
-- SELECT * FROM RouteInclude; -- reference
-- SELECT * FROM rt_stA_combo; -- includes all lines that stop at station "A"
-- SELECT * FROM rt_stB_combo; -- includes all lines that stop at station "B"

-- Testing java generated strings:
-- CREATE OR REPLACE VIEW rt_stA_combo AS SELECT * FROM RouteInclude WHERE station_id = '2' AND stop = 'true';
-- CREATE OR REPLACE VIEW rt_stB_combo AS SELECT * FROM RouteInclude WHERE station_id = '4' AND stop = 'true';
--

-- RUN THIS
CREATE OR REPLACE procedure rtAB_comboProcedure()
language plpgsql AS $$
begin

    -- RUN THIS
    CREATE OR REPLACE VIEW rtA_combo AS
        SELECT RouteInclude.route_id AS routeID, rt_sta_combo.station_id AS start_station, RouteInclude.station_id AS stopsAtstation, RouteInclude.stop AS stop
        FROM RouteInclude
        INNER JOIN rt_stA_combo ON rt_stA_combo.route_id = RouteInclude.route_id
        AND RouteInclude.stop = 'true'; -- if the route only passes through the station, we cannot use it as a layover

    -- RUN THIS
    CREATE OR REPLACE VIEW rtB_combo AS
        SELECT RouteInclude.route_id AS routeID, rt_stb_combo.station_id AS end_station, RouteInclude.station_id AS stopsAtstation, RouteInclude.stop AS stop
        FROM RouteInclude
        INNER JOIN rt_stB_combo ON rt_stB_combo.route_id = RouteInclude.route_id
        AND RouteInclude.stop = 'true'; -- if the route only passes through the station, we cannot use it as a layover

end;
$$;

-- SELECT * FROM rtA_combo; -- includes every stop from routes that stop at station A
-- SELECT * FROM rtB_combo; -- includes every stop from routes that stop at station B
-- CALL rtAB_comboProcedure(); -- program calls this statement

-- find all routes that stop at station AB on Tuesday
-- the following statements are generates in java:
-- CREATE OR REPLACE VIEW day_StationA_combo AS
--     SELECT rtA_combo.routeID AS route, start_station, stopsatstation, day, time, train_id
--     FROM rtA_combo
--     INNER JOIN Route_Schedules ON rtA_combo.routeID = Route_Schedules.routeid
--     AND Route_Schedules.day = 'Tuesday';

-- CREATE OR REPLACE VIEW day_StationB_combo AS
--     SELECT rtB_combo.routeID AS route, end_station, stopsatstation, day, time, train_id
--     FROM rtB_combo
--     INNER JOIN Route_Schedules ON rtB_combo.routeID = Route_Schedules.routeid
--     AND Route_Schedules.day = 'Tuesday';

-- SELECT * FROM day_StationA_combo; --contains only the routes that stop at station a on tuesday
-- SELECT * FROM day_StationB_combo; --contains only the routes that stop at station b on tuesday

-- tested output strings:
-- CREATE OR REPLACE VIEW day_StationA_combo AS SELECT rtA_combo.routeID AS route, start_station, stopsatstation, day, time, train_id FROM rtA_combo INNER JOIN Route_Schedules ON rtA_combo.routeID = Route_Schedules.routeid AND Route_Schedules.day = 'Tuesday';
-- CREATE OR REPLACE VIEW day_StationB_combo AS SELECT rtB_combo.routeID AS route, end_station, stopsatstation, day, time, train_id FROM rtB_combo INNER JOIN Route_Schedules ON rtB_combo.routeID = Route_Schedules.routeid AND Route_Schedules.day = 'Tuesday';

-- RUN THIS
CREATE OR REPLACE procedure rtAB_comboMatch()
language plpgsql AS $$
begin

    -- RUN THIS
    CREATE OR REPLACE VIEW daySTA_Combo_seats AS --adds seatcount functionality
        SELECT route, start_station AS startstation , stopsatstation, day_stationa_combo.day, day_stationa_combo.time, day_stationa_combo.train_id, seat_count AS trainaseatcount
        FROM day_stationa_combo
        INNER JOIN stop_seatcount ON day_stationa_combo.route = stop_seatcount.route_id
        AND day_stationa_combo.day = stop_seatcount.day
        AND day_stationa_combo.time = stop_seatcount.time
        AND day_stationa_combo.stopsatstation = stop_seatcount.station_number
        AND seat_count > 0;

    -- RUN THIS
    CREATE OR REPLACE VIEW daySTB_Combo_seats AS --adds seatcount functionality
        SELECT route, end_station AS endstation, stopsatstation, day_stationb_combo.day, day_stationb_combo.time, day_stationb_combo.train_id, seat_count AS trainbseatcount
        FROM day_stationb_combo
        INNER JOIN stop_seatcount ON day_stationb_combo.route = stop_seatcount.route_id
        AND day_stationb_combo.day = stop_seatcount.day
        AND day_stationb_combo.time = stop_seatcount.time
        AND day_stationb_combo.stopsatstation = stop_seatcount.station_number
        AND seat_count > 0;

    -- RUN THIS
    CREATE OR REPLACE VIEW comboMatch AS
        SELECT daySTA_Combo_seats.day AS day, daySTA_Combo_seats.time AS starttime, daySTA_Combo_seats.startstation, daySTA_Combo_seats.route AS routeA, daySTA_Combo_seats.train_id AS trainA, daySTA_Combo_seats.trainaseatcount AS trainAseatcount,
           daySTA_Combo_seats.stopsatstation AS layover_station, daySTB_Combo_seats.time AS endTime,
           daySTB_Combo_seats.route AS routeB,daySTB_Combo_seats.train_id AS trainB, daySTB_Combo_seats.trainbseatcount, daySTB_Combo_seats.endstation
        FROM daySTA_Combo_seats
        INNER JOIN daySTB_Combo_seats ON daySTA_Combo_seats.stopsatstation = daySTB_Combo_seats.stopsatstation
        AND daySTA_Combo_seats.route != daySTB_Combo_seats.route; --removes single route trips

    -- RUN THIS
    CREATE OR REPLACE VIEW comboView1 AS
        SELECT day, starttime, startstation, routea, traina, top_speed AS trainAspeed, cost_per_mile as trainAcost, trainaseatcount, layover_station, endtime, routeb, trainb, trainbseatcount, endstation
        FROM combomatch
        INNER JOIN trains ON trains.train_id = combomatch.traina;

    -- RUN THIS
    CREATE OR REPLACE VIEW comboView2 AS
        SELECT day, starttime, startstation AS startstation, routea, traina, trainaspeed, trainacost, trainaseatcount, layover_station AS layover,
               endtime, routeb, trainb, top_speed AS trainBspeed, cost_per_mile as trainBcost, trainbseatcount, endstation AS endstation
        FROM comboview1
        INNER JOIN trains ON trains.train_id = comboview1.trainb;

    -- RUN THIS
    CREATE OR REPLACE VIEW comboByPrice AS
        SELECT * FROM comboview2
        ORDER BY trainacost, trainbcost;

    -- RUN THIS
    CREATE OR REPLACE VIEW comboByTime AS
        SELECT * FROM comboview2
        ORDER BY trainaspeed DESC, trainbspeed DESC;

    -- RUN THIS
    CREATE OR REPLACE VIEW fewestStopCombo AS
        SELECT route_id, count(route_id) AS stopcount
        FROM routeinclude
        WHERE stop = 'true'
        GROUP BY route_id;

    -- RUN THIS
    CREATE OR REPLACE VIEW fewestStopComboA AS
        SELECT day, starttime, startstation, routea, traina, trainaseatcount, stopcount AS stopcountA, layover, endtime, routeb, trainb, trainbseatcount, endstation
        FROM comboview2
        INNER JOIN fewestStopCombo ON fewestStopCombo.route_id = comboview2.routea;

    -- RUN THIS
    CREATE OR REPLACE VIEW fewestStopComboAB AS
        SELECT day, starttime, startstation, routea, traina, trainaseatcount, stopcounta, layover, endtime, routeb, trainb, trainbseatcount,stopcount AS stopcountB, endstation
        FROM fewestStopComboA
        INNER JOIN fewestStopCombo ON fewestStopComboA.routeb = fewestStopCombo.route_id;

    -- RUN THIS
    CREATE OR REPLACE VIEW combobystops AS
        SELECT * FROM fewestStopComboAB
        ORDER BY stopcounta, stopcountb;

    -- RUN THIS
    CREATE OR REPLACE VIEW fewestStationCombo AS
        SELECT route_id, COUNT(route_id) AS stationcount
        FROM routeinclude
        GROUP BY route_id;

    -- RUN THIS
    CREATE OR REPLACE VIEW fewestStationComboA AS
        SELECT Day, starttime, startstation, routea, traina, trainaseatcount, stationcount AS Astationcount, layover, endtime, routeb, trainb, trainbseatcount, endstation
        FROM fewestStationCombo
        INNER JOIN comboview2 ON fewestStationCombo.route_id = comboview2.routea;

    -- RUN THIS
    CREATE OR REPLACE VIEW fewestStationComboAB AS
        SELECT Day, starttime, startstation, routea, traina, trainaseatcount, Astationcount, layover, endtime,
               routeb, trainb, trainbseatcount, stationcount AS bstationcount, endstation
        FROM fewestStationComboA
        INNER JOIN fewestStationCombo ON fewestStationCombo.route_id = fewestStationComboA.routeb;

    -- RUN THIS
    CREATE OR REPLACE VIEW combobystations AS
        SELECT * from fewestStationComboAB
        ORDER BY Astationcount, bstationcount;

end;
$$;

-- RUN THIS
-- CALL rtAB_comboMatch();

-- routea stops at station a and the layover_station
-- routeb stops at the layover_station and station b

-- SELECT * FROM comboMatch; -- do not use
-- SELECT * FROM comboview1; -- do not use

--SELECT * FROM comboview2; -- do not use

--SELECT * FROM combobyprice; -- called by java program, will not work without running a combination search in java

-- time appears to produce an incorrect output because the time listed is the scheduled time that the route BEGINS running,
-- not necessarily when the train stops at each route.
--SELECT * FROM combobytime; -- called by java program, will not work without running a combination search in java
--SELECT * FROM combobystops; -- called by java program, will not work without running a combination search in java
--SELECT * FROM combobystations; -- called by java program, will not work without running a combination search in java








