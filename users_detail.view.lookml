- view: users_detail
  sql_table_name: demo_db.users
  fields:
  
######## Dimensions ########

  - dimension: id
    primary_key: true
    hidden: true
    type: number
    sql: ${TABLE}.id

  - dimension: age
    type: number
    sql: ${TABLE}.age

  - dimension: city
    type: string
    sql: ${TABLE}.city

  - dimension: country
    type: string
    sql: ${TABLE}.country

  - dimension_group: created
    type: time
    timeframes: [date, week, month, year]
    sql: ${TABLE}.created_at

  - dimension: email
    type: string
    sql: ${TABLE}.email

  - dimension: first_name
    type: string
    sql: ${TABLE}.first_name

  - dimension: gender
    type: string
    sql: ${TABLE}.gender

  - dimension: last_name
    type: string
    sql: ${TABLE}.last_name

  - dimension: state
    type: string
    map_layer: us_states
    sql: ${TABLE}.state

  - dimension: zip
    type: zipcode
    map_layer: us_zipcode_tabulation_areas
    sql: ${TABLE}.zip

######## Measures ########

  - measure: count
    type: count
    drill_fields: detail*

  - measure: days_to_buy
    type: number
    sql: datediff(${user_data.first_order_date}, ${created_date})
    
  - measure: transactions_per_user
    type: number
    sql: ${order_facts.gross_order_count}/${count}
    value_format_name: decimal_2


  # ----- Sets of fields for drilling ------
  sets:
    detail:
    - id
    - last_name
    - first_name
    - events.count
    - orders.count
    - user_data.count

