- view: order_value
  derived_table:
    sql: |
      SELECT
         o.id AS id
        ,sum(i.sale_price) AS order_sale_price
        ,count(distinct i.id) AS items_per_order
      FROM order_items i
      LEFT JOIN orders o
      ON i.order_id = o.id
      GROUP BY id


  
##### In redshift: #####
  # derived_table:
  #   sql_trigger_value: SELECT MAX(id) FROM orders
  #   indexes: [id]
  #   sql: |
  #     SELECT 
  #       o.id AS id
  #       ,o.created_at
  #       ,o.status
  #       ,o.user_id
  #       ,rank() over (partition by o.user_id order by o.created_at asc) AS order_number
  #       ,max.max_date
  #       ,sum(i.sale_price) AS order_sale_price
  #       ,count(distinct i.id) AS items_per_order
  #     FROM orders AS o
  #     LEFT JOIN order_items i
  #     ON o.id = i.id
  #     CROSS JOIN
  #         (SELECT
  #           MAX(orders.created_at) AS max_date
  #         FROM orders) max
  #     ORDER BY user_id ASC, order_number ASC
  


- view: order_facts
  derived_table:
    sql_trigger_value: SELECT MAX(id) FROM orders
    indexes: [id]
    sql: |
      SELECT 
         o.id AS id
        ,o.created_at AS created_at
        ,o.status AS status
        ,o.user_id AS user_id
        ,(SELECT COUNT(*) + 1
          FROM orders
          WHERE created_at < o.created_at AND user_id = o.user_id
          ORDER BY created_at ASC
          ) AS user_order_sequence_number
        ,max.max_date AS max_date
        ,order_value.order_sale_price AS order_sale_price
        ,order_value.items_per_order AS items_per_order
      FROM orders o
      LEFT JOIN ${order_value.SQL_TABLE_NAME} AS order_value
      ON o.id = order_value.id
      CROSS JOIN
          (SELECT
            MAX(orders.created_at) AS max_date
          FROM orders) max
      GROUP BY id, user_id
      ORDER BY user_id ASC, user_order_sequence_number ASC
      
    
  fields:
  
######## Dimensions ########
  
  - dimension: id
    primary_key: true
    # hidden: true
    type: number
    sql: ${TABLE}.id

  - dimension: status
    type: string
    sql: ${TABLE}.status

  - dimension: user_id
    type: number
    # hidden: true
    sql: ${TABLE}.user_id
    
  - dimension: user_order_sequence_number
    type: number
    sql: ${TABLE}.user_order_sequence_number
    
  - dimension: is_first_purchase
    type: yesno
    sql: ${user_order_sequence_number} = 1  
    
######## Time Dimensions ########
    
  - dimension_group: created
    type: time
    timeframes: [date, week, month, month_name, year]
    sql: ${TABLE}.created_at
    
  - dimension_group: max
    type: time
    timeframes: [date, week, month, year]
    sql: ${TABLE}.max_date
    
  - dimension: is_before_mtd
    type: yesno
    sql: |
      (EXTRACT(DAY FROM ${created_date}) < EXTRACT(DAY FROM ${max_date}))
      
  - dimension: current_month_flag
    type: yesno
    sql: ${created_month} = ${max_month}
    
  - dimension: days_since_signup
    type: number
    sql: DATEDIFF(${created_date}, ${users.created_date})
    
######## Measures ########

  - measure: gross_order_count
    type: count
    description: 'Count of all orders placed, including orders that were later cancelled'
    drill_fields: detail*
    
  - measure: net_order_count
    type: count
    description: 'Count of all completed and pending orders. Cancelled orders are excluded'
    filter:
      status: -'cancelled'
    
  - measure: total_order_revenue
    type: sum
    description: 'Total revenue from completed and pending orders. Cancelled orders are excluded'
    sql: ${TABLE}.order_sale_price
    filter:
      status: -'cancelled'
    value_format_name: usd
    
  - measure: average_revenue_per_order
    type: avg
    sql: ${TABLE}.order_sale_price
    value_format_name: usd
    
  - measure: average_items_per_order
    type: avg
    sql: ${TABLE}.items_per_order
    value_format_name: decimal_2
    
######## Basic Revenue Projections ########
  - measure: number_of_days_per_month
    type: max
    hidden: true
    sql: DAY(LAST_DAY(${created_date}))
  
  - measure: days_elapsed_by_month
    type: max
    hidden: true
    sql: DAY(${created_date})
      
  - measure: days_to_go_by_month
    type: number
    hidden: true
    sql: ${number_of_days_per_month} - ${days_elapsed_by_month}
      
  - measure: order_revenue_per_day
    type: number
    hidden: true
    sql: ${total_order_revenue}/NULLIF(${days_elapsed_by_month},0)
  
  - measure: orders_per_day
    type: number
    hidden: true
    sql: ${net_order_count}/${days_elapsed_by_month}
    value_format_name: decimal_2
    
  - measure: projected_order_count
    type: number
    description: 'Estimates future orders for the current month based on performance so far in the month. Completed months show net order counts.'
    sql: (${days_to_go_by_month}*${orders_per_day}) + ${net_order_count}
    value_format_name: decimal_0
    html: |
      {% if created_month._value ==  max_month._value %}
      <p style="color: #929292">{{ rendered_value }}</p>
      {% else %}
      <p style="color: #4c4c4c">{{ rendered_value }}</p>
      {% endif %}
      

  - measure: projected_revenue
    type: number
    description: 'Estimates future revenue for the current month based on performance so far in the month. Completed months show total revenue values.'
    sql: ${days_to_go_by_month}*${order_revenue_per_day} + ${total_order_revenue}
    value_format_name: usd
    html: |
      {% if created_month._value ==  max_month._value %}
      <p style="color: #929292; background-color: white">{{ rendered_value }}</p>
      {% else %}
      <p style="color: #4c4c4c; background-color: gray">{{ rendered_value }}</p>
      {% endif %}
    
# ----- Sets of fields for drilling ------
  sets:
    detail:
    - id
    - users.last_name
    - users.first_name
    - users.id
    - order_items.count
