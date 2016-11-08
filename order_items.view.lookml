- view: order_items
  sql_table_name: demo_db.order_items
  fields:
  
######## Dimensions ########

  - dimension: id
    primary_key: true
    type: number
    sql: ${TABLE}.id

  - dimension: inventory_item_id
    type: number
    hidden: true
    sql: ${TABLE}.inventory_item_id

  - dimension: order_id
    type: number
    hidden: true
    sql: ${TABLE}.order_id
    
  - dimension: sale_price
    type: number
    hidden: true
    sql: ${TABLE}.sale_price
    
  - dimension: item_margin
    type: number
    hidden: true
    sql: ${sale_price} - ${inventory_items.cost}
    
######## Time Dimensions ########

  - dimension_group: returned
    type: time
    timeframes: [date, week, month, year]
    sql: ${TABLE}.returned_at

######## Measures ########

  - measure: count
    type: count
    drill_fields: [products.department, products.category, products.brand]
    
  - measure: total_paid_amount
    type: sum
    description: 'Total amount paid by customer for items ordered. This does not account for items that were returned.'
    sql: ${sale_price}
    value_format_name: usd
    
  - measure: average_sale_price
    type: avg
    sql: ${sale_price}
    value_format_name: usd
    
  - measure: gross_revenue
    type: sum
    description: 'Revenue from all sold items that were not cancelled or returned by the customer.'
    sql: ${sale_price}
    filters:
      order_facts.status: -'cancelled'
      returned_date: NULL()
    value_format_name: usd
    drill_fields: product_detail*
    
  - measure: gross_cost
    type: sum
    description: 'Cost of all sold items that were not cancelled or returned by the customer.'
    sql: ${inventory_items.cost}
    filters:
      order_facts.status: -'cancelled'
      returned_date: NULL()
    value_format_name: usd
    drill_fields: product_detail*
    
  - measure: gross_margin_for_scatter
    type: number
    description: 'Total margin from all sold items that were not cancelled or returned by the customer.'
    sql: ${gross_revenue} - ${gross_cost}
    value_format_name: usd
    drill_fields: product_detail*
    html: |
     {{ rendered_value }} || {{ products.product_drill }} 
  
  - measure: gross_margin
    type: number
    description: 'Total margin from all sold items that were not cancelled or returned by the customer.'
    sql: ${gross_revenue} - ${gross_cost}
    value_format_name: usd
    drill_fields: product_detail*
    
  - measure: items_ordered_per_user
    type: number
    description: 'Average number of items ordered per registered user'
    sql: ${count}/${users.count}
    value_format_name: decimal_2
    
  - measure: items_ordered_per_transaction
    type: number
    description: 'Average number of items purchased within a single order'
    sql: ${count}/${order_facts.gross_order_count}
    value_format_name: decimal_2
    
  - measure: count_of_women
    type: count
    filters:
      users.gender: 'f'
    html: |
      {% if volume._value < 10000 %}
      <div> null </div>
      {% else %}
      <div> {{ rendered_value }}</div>
      {% endif %}
    
    
# ----- Sets of fields for drilling ------
  sets:
    product_detail:
    - id
    - products.department
    - products.category
    - products.brand
    - products.sku

