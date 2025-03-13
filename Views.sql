CREATE
OR REPLACE VIEW "common"."airports_severe_complaints_view" AS
SELECT
   complaint_fact.airport_id,
   avg(
      date_diff(
         'day':: character varying:: text,
         to_date(
            complaint_fact.createdon:: character varying:: text,
            'YYYYMMDD':: character varying:: text
         ):: timestamp without time zone,
         to_date(
            complaint_fact.resolvedon:: character varying:: text,
            'YYYYMMDD':: character varying:: text
         ):: timestamp without time zone
      )
   ) AS avg_resolution_time
FROM
   common.complaint_fact
WHERE
   complaint_fact.resolvedon IS NOT NULL
GROUP BY
   complaint_fact.airport_id
ORDER BY
   avg(
      date_diff(
         'day':: character varying:: text,
         to_date(
            complaint_fact.createdon:: character varying:: text,
            'YYYYMMDD':: character varying:: text
         ):: timestamp without time zone,
         to_date(
            complaint_fact.resolvedon:: character varying:: text,
            'YYYYMMDD':: character varying:: text
         ):: timestamp without time zone
      )
   ) DESC
LIMIT
   5;


CREATE
OR REPLACE VIEW "common"."avg_points_redeemed_view" AS
SELECT
    p.gender,
    p.age_category,
    p.loyalty_tier,
    avg(
        CASE
        WHEN l.points_type:: text = 'Redeemed':: text THEN l.points
        ELSE NULL:: numeric END
    ) AS avg_points_redeemed,
    avg(
        CASE
        WHEN l.points_type:: text = 'Earned':: text THEN l.points
        ELSE NULL:: numeric END
    ) AS avg_points_earned
FROM
    common.loyalty_program_fact l
    JOIN common.passenger_dim p ON l.passenger_id = p.passenger_id
GROUP BY
    p.gender,
    p.age_category,
    p.loyalty_tier;

CREATE
OR REPLACE VIEW "common"."avg_respone_satisfaction_viw" AS
SELECT
   ccd.category_name,
   d.fiscal_year,
   d.fiscal_month_number_in_year,
   avg(i.response_time) AS avg_response_time,
   avg(i.satisfaction_score) AS avg_satisfaction
FROM
   common.complaint_fact c
   JOIN common.interaction_fact i ON c.employee_id = i.employee_id
   JOIN common.date_dim d ON c.createdon = d.date_id
   JOIN common.complaint_category_dim ccd ON ccd.complaint_category_id = c.complaint_category_id
GROUP BY
   ccd.category_name,
   d.fiscal_year,
   d.fiscal_month_number_in_year
ORDER BY
   d.fiscal_year,
   d.fiscal_month_number_in_year;


CREATE
OR REPLACE VIEW "common"."cancellations_view" AS
SELECT
   p.gender,
   p.age_category,
   p.loyalty_tier,
   count(r.reservation_id) AS total_cancellations
FROM
   common.reservation_tracking_fact r
   JOIN common.passenger_dim p ON r.passenger_id = p.passenger_id
WHERE
   to_date(
      r.reservation_upgrade:: character varying:: text,
      'YYYY-MM-DD':: text
   ) <> '1900-01-01':: date
GROUP BY
   p.gender,
   p.age_category,
   p.loyalty_tier;


CREATE
OR REPLACE VIEW "common"."earned_view" AS
SELECT
   d.category,
   count(*) AS total_earned
FROM
   common.loyalty_program_fact l
   JOIN common.dim_promotion d ON l.promotion_id = d.promotion_id
WHERE
   l.points_type:: text = 'Earned':: text
GROUP BY
   d.category;

CREATE
OR REPLACE VIEW "common"."feedbacks_view" AS
SELECT
   p.gender,
   p.age_category,
   p.loyalty_tier,
   count(r.flight_feedback) AS total_feedbacks
FROM
   common.reservation_tracking_fact r
   JOIN common.passenger_dim p ON r.passenger_id = p.passenger_id
WHERE
   r.flight_feedback IS NOT NULL
GROUP BY
   p.gender,
   p.age_category,
   p.loyalty_tier;


CREATE
OR REPLACE VIEW "common"."monthly_revenue_trend_view" AS
SELECT
   d.calendar_year,
   d.fiscal_month,
   sum(r.revenue) AS total_revenue
FROM
   common.reservation_fact r
   JOIN common.date_dim d ON r.date_id = d.date_id
GROUP BY
   d.calendar_year,
   d.fiscal_month
ORDER BY
   d.calendar_year,
   d.fiscal_month;


CREATE
OR REPLACE VIEW "common"."most_profitable_airports_view" AS
SELECT
   a.airport_name,
   a.city,
   a.country,
   sum(r.profit) AS total_profit
FROM
   common.reservation_fact r
   JOIN common.airport_dim a ON r.airport_code:: text = a.airport_code:: text
GROUP BY
   a.airport_name,
   a.city,
   a.country
ORDER BY
   sum(r.profit) DESC
LIMIT
   10;

CREATE
OR REPLACE VIEW "common"."overnight_stay_view" AS
SELECT
    p.loyalty_tier,
    p.membership_status,
    sum(o.duration) AS total_duration,
    count(o.stay_id) AS total_stays,
    sum(o.duration) / CASE
    WHEN count(o.stay_id) = 0 THEN NULL:: bigint
    ELSE count(o.stay_id) END AS avg_duration_ratio
FROM
    common.overnight_stay_fact o
    JOIN common.passenger_dim p ON o.passenger_id = p.passenger_id
GROUP BY
    p.loyalty_tier,
    p.membership_status;

CREATE
OR REPLACE VIEW "common"."redeemed_view" AS
SELECT
   d.category,
   count(*) AS total_redeemed
FROM
   common.loyalty_program_fact l
   JOIN common.dim_promotion d ON l.promotion_id = d.promotion_id
WHERE
   l.points_type:: text = 'Redeemed':: text
GROUP BY
   d.category;


CREATE
OR REPLACE VIEW "common"."revenue_by_age_view" AS
SELECT
   p.age_category,
   sum(r.revenue) AS total_revenue
FROM
   common.reservation_fact r
   JOIN common.passenger_dim p ON r.passenger_id = p.passenger_id
GROUP BY
   p.age_category
ORDER BY
   sum(r.revenue) DESC;

CREATE
OR REPLACE VIEW "common"."revenue_by_channel_view" AS
SELECT
   reservation_fact.reservation_channel,
   count(*) AS number_of_reservations,
   sum(reservation_fact.revenue) AS total_revenue,
   sum(reservation_fact.profit) AS total_profit
FROM
   common.reservation_fact
GROUP BY
   reservation_fact.reservation_channel;


CREATE
OR REPLACE VIEW "common"."revenue_by_paymentmethd_view" AS
SELECT
   reservation_fact.payment_method,
   count(*) AS number_of_reservations,
   sum(reservation_fact.revenue) AS total_revenue
FROM
   common.reservation_fact
GROUP BY
   reservation_fact.payment_method
ORDER BY
   count(*) DESC;
   
CREATE
OR REPLACE VIEW "common"."revenue_by_promotion_view" AS
SELECT
   p.name AS promotion_name,
   sum(r.revenue) AS total_revenue
FROM
   common.reservation_fact r
   JOIN common.dim_promotion p ON r.promotion_id = p.promotion_id
GROUP BY
   p.name
ORDER BY
   sum(r.revenue) DESC;
   
   
   CREATE
OR REPLACE VIEW "common"."satisfaction_variance_view" AS
SELECT
   interaction_fact.interaction_channel,
   round(
      variance(
         interaction_fact.satisfaction_score:: double precision
      ),
      2:: numeric:: numeric(18, 0)
   ) AS satisfaction_variance
FROM
   common.interaction_fact
GROUP BY
   interaction_fact.interaction_channel;

CREATE
OR REPLACE VIEW "common"."unresolved_cases_view" AS
SELECT
    ccd.category_name,
    round(
        count(
            CASE
            WHEN c.complaint_status:: text <> 'Resolved':: character varying:: text THEN 1
            ELSE NULL:: integer END
        ):: numeric:: numeric(18, 0) * 100.0 / count(*):: numeric:: numeric(18, 0),
        2
    ) AS unresolved_percentage
FROM
    common.complaint_fact c
    JOIN common.complaint_category_dim ccd ON ccd.complaint_category_id = c.complaint_category_id
GROUP BY
    ccd.category_name
ORDER BY
    round(
        count(
            CASE
            WHEN c.complaint_status:: text <> 'Resolved':: character varying:: text THEN 1
            ELSE NULL:: integer END
        ):: numeric:: numeric(18, 0) * 100.0 / count(*):: numeric:: numeric(18, 0),
        2
    ) DESC;

CREATE
OR REPLACE VIEW "common"."upgrades_view" AS
SELECT
   p.gender,
   p.age_category,
   p.loyalty_tier,
   count(r.reservation_id) AS total_upgrades
FROM
   common.reservation_tracking_fact r
   JOIN common.passenger_dim p ON r.passenger_id = p.passenger_id
WHERE
   to_date(
      r.reservation_upgrade:: character varying:: text,
      'YYYY-MM-DD':: text
   ) <> '1900-01-01':: date
GROUP BY
   p.gender,
   p.age_category,
   p.loyalty_tier;


