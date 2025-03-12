--loyalty_program_fact-overNight_stay_fact
--Count of Overnight Stays
SELECT COUNT(*) AS total_overnight_stays
FROM OverNight_stay_fact;

-- Ratio of Night Stay Duration for Each Tier and Membership Status
SELECT 
    p.loyalty_tier,
    p.membership_status,
    SUM(o.Duration) AS total_duration,
    COUNT(o.StayID) AS total_stays,
    SUM(o.Duration) / NULLIF(COUNT(o.StayID), 0) AS avg_duration_ratio
FROM OverNight_stay_fact o
JOIN Passenger_DIM p ON o.Passanger_id = p.Passanger_ID
GROUP BY p.loyalty_tier, p.membership_status;

--Count of Each Location Type (Overall, by Tier, Membership, and Airport)
SELECT StayLocation_Type, COUNT(*) AS total_count
FROM OverNight_stay_fact
GROUP BY StayLocation_Type;

SELECT p.loyalty_tier, StayLocation_Type, COUNT(*) AS total_count
FROM OverNight_stay_fact o
JOIN Passenger_DIM p ON o.Passanger_id = p.Passanger_ID
GROUP BY p.loyalty_tier, StayLocation_Type;

SELECT p.membership_status, StayLocation_Type, COUNT(*) AS total_count
FROM OverNight_stay_fact o
JOIN Passenger_DIM p ON o.Passanger_id = p.Passanger_ID
GROUP BY p.membership_status, StayLocation_Type;

SELECT o.Airpot_code, StayLocation_Type, COUNT(*) AS total_count
FROM OverNight_stay_fact o
GROUP BY o.Airpot_code, StayLocation_Type;

--Average Points for Each Tier and Membership Status
SELECT p.loyalty_tier, p.membership_status, AVG(l.Points) AS avg_points
FROM Loyalty_program_fact l
JOIN Passenger_DIM p ON l.passenger_id = p.Passanger_ID
GROUP BY p.loyalty_tier, p.membership_status;


--Count of Each Tier
SELECT loyalty_tier, COUNT(*) AS total_count
FROM Passenger_DIM
GROUP BY loyalty_tier;

--Count of Points Redeemed for Each Promotion Category
SELECT d.promotion_category, COUNT(*) AS total_redeemed
FROM Loyalty_program_fact l
JOIN Dim_Promotion d ON l.Promotion_id = d.promotion_id
WHERE l.Operation_Type = 'Redeem'
GROUP BY d.promotion_category;

--Count of Points Earned for Each Promotion Category
SELECT d.promotion_category, COUNT(*) AS total_earned
FROM Loyalty_program_fact l
JOIN Dim_Promotion d ON l.Promotion_id = d.promotion_id
WHERE l.Operation_Type = 'Earn'
GROUP BY d.promotion_category;

--Average Points Redeemed and Earned for Each Gender, Nationality, Age Group, and Tier
SELECT 
    p.Gender,
    p.nationality,
    p.age_category,
    p.loyalty_tier,
    AVG(CASE WHEN l.Operation_Type = 'Redeem' THEN l.Points ELSE NULL END) AS avg_points_redeemed,
    AVG(CASE WHEN l.Operation_Type = 'Earn' THEN l.Points ELSE NULL END) AS avg_points_earned
FROM Loyalty_program_fact l
JOIN Passenger_DIM p ON l.passenger_id = p.Passanger_ID
GROUP BY p.Gender, p.nationality, p.age_category, p.loyalty_tier;

--Average Points Redeemed and Earned on Holidays in Each Country
SELECT 
    c.Country_Name,
    AVG(CASE WHEN l.Operation_Type = 'Redeem' THEN l.Points ELSE NULL END) AS avg_points_redeemed,
    AVG(CASE WHEN l.Operation_Type = 'Earn' THEN l.Points ELSE NULL END) AS avg_points_earned
FROM Loyalty_program_fact l
JOIN Dim_Date d ON l.date = d.Date(ddmmyyyy)
JOIN Country_Specific_Date_Outrigger c ON d.Date(ddmmyyyy) = c.Date_Key
WHERE c.Religious_Holiday_Flag = 1 OR c.Civil_Holiday_Flag = 1
GROUP BY c.Country_Name;
-------------------------------------------------------------------------------------------------------------------

--tracking_fact
--Count of Upgrades for Each Gender, Nationality, Age Group, and Tier
SELECT 
    p.Gender,
    p.nationality,
    p.age_category,
    p.loyalty_tier,
    COUNT(r.Reservation_tracking_id) AS total_upgrades
FROM Reservation_Tracking_fact r
JOIN Passenger_DIM p ON r.Passanger_id = p.Passanger_ID
WHERE r.Reservation_upgrade <> '9999-12-31'
GROUP BY p.Gender, p.nationality, p.age_category, p.loyalty_tier;

--Count of Cancellations for Each Gender, Nationality, Age Group, and Tier
SELECT 
    p.Gender,
    p.nationality,
    p.age_category,
    p.loyalty_tier,
    COUNT(r.Reservation_tracking_id) AS total_cancellations
FROM Reservation_Tracking_fact r
JOIN Passenger_DIM p ON r.Passanger_id = p.Passanger_ID
WHERE r.Reservation_cancel_date <> '9999-12-31'
GROUP BY p.Gender, p.nationality, p.age_category, p.loyalty_tier;

--Feedback Count for Each Gender, Nationality, Age Group, and Tier
SELECT 
    p.Gender,
    p.nationality,
    p.age_category,
    p.loyalty_tier,
    COUNT(r.Flight_Feedback) AS total_feedbacks
FROM Reservation_Tracking_fact r
JOIN Passenger_DIM p ON r.Passanger_id = p.Passanger_ID
WHERE r.Flight_Feedback IS NOT NULL
GROUP BY p.Gender, p.nationality, p.age_category, p.loyalty_tier;


    ------------------------------------------------------------------------------
--flight activity fact
-- Count of delayed flights
SELECT 
    COUNT(*) AS delayed_flights 
FROM flight_activity 
WHERE Actual_Departure_Time > Departure_time;
    -- OR Actual_Arrival_Time > Arrival_Time;


--	Count of empty seats, occupied seats for each class

SELECT 
    SUM(Empty_Seats_Business) AS Total_Empty_Seats_Business,
    SUM(Empty_Seats_FirtClass) AS Total_Empty_Seats_FirstClass,
    SUM(Empty_Seats_Economy) AS Total_Empty_Seats_Economy,
    SUM(Occupied_Seats_Business) AS Total_Occupied_Seats_Business,
    SUM(Occupied_Seats_Economy) AS Total_Occupied_Seats_Economy,
    SUM(Occupied_Seats_FirstClass) AS Total_Occupied_Seats_FirstClass
FROM 
    Flight_Activity;

--	Impact of baggage weight on delayed flights
	SELECT 
	    CASE 
	        WHEN Actual_Departure_Time > Departure_Time THEN 'Delayed'
	        ELSE 'On Time'
	    END AS flight_status,
	    AVG(Baggage_Weight) AS avg_baggage_weight
	FROM flight_activity
	GROUP BY flight_status;


--	Gender and age distribution of crew members (especially captains)
  SELECT 
    Gender,
    Age,
    COUNT(*) AS crew_count
FROM dim_crew 
WHERE role_descreption = 'Captain'
GROUP BY Gender, Age
ORDER BY Age;

•	Number of flights per captain
SELECT 
Captain_ID,  
    COUNT(*) AS Flights_Count
FROM 
    Flight_Activity
GROUP BY 
Captain_ID
ORDER BY 
    Flights_Count DESC;


--Cases where crew count exceeds capacity (TBC)

SELECT 
    f.flight_id, 
    a.airplane_id, 
    COUNT(c.crew_id) AS assigned_crew, 
    a.max_capacity
FROM fact_flight_activity f
JOIN dim_airplanes a ON f.airplane_id = a.airplane_id
JOIN dim_crew c ON f.captain_id = c.crew_id OR f.co_captain_id = c.crew_id
GROUP BY f.flight_id, a.airplane_id, a.max_capacity
HAVING assigned_crew > a.max_capacity;




