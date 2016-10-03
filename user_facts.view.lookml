
- view: user_facts
  derived_table:
    sql: |
      SELECT
         users.id AS id
        ,users.created_at AS user_signup_date
        ,MIN(orders.created_at) AS user_first_order
      FROM users
      LEFT JOIN orders ON users.id = orders.user_id
      GROUP BY 1, 2
    sql_trigger_value: SELECT MAX(id) FROM demo_db.users
    indexes: [id]

  fields:
  - dimension: id
    type: number
    primary_key: true
    sql: ${TABLE}.id

  - dimension_group: user_signup
    timeframes: [date, week, month, year]
    type: time
    sql: ${TABLE}.user_signup_date

  - dimension_group: user_first_order
    timeframes: [date, week, month, year]
    type: time
    sql: ${TABLE}.user_first_order
    
  - dimension: days_from_signup_to_order
    type: number
    sql: DATEDIFF(${user_first_order_date}, ${user_signup_date})
    
  - measure: average_days_from_signup_to_order
    type: average
    sql: ${days_from_signup_to_order}


  sets:
    detail:
      - id
      - user_signup_date_time
      - user_first_order_time

