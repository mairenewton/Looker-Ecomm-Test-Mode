- view: products
  sql_table_name: demo_db.products
  fields:
  
######## Dimensions ########

  - dimension: id
    primary_key: true
    type: number
    hidden: true
    sql: ${TABLE}.id

  - dimension: brand
    type: string
    sql: ${TABLE}.brand

  - dimension: category
    type: string
    sql: ${TABLE}.category

  - dimension: department
    type: string
    sql: ${TABLE}.department

  - dimension: item_name
    type: string
    sql: ${TABLE}.item_name

  - dimension: rank
    type: number
    sql: ${TABLE}.rank

  - dimension: retail_price
    type: number
    hidden: true
    sql: ${TABLE}.retail_price

  - dimension: sku
    type: string
    sql: ${TABLE}.sku
    
######## Custom Product Drill ########
  
  - filter: selected_category
    suggest_dimension: category
    
  - filter: selected_brand
    suggest_dimension: brand

  - dimension: product_drill
    sql: |
      CASE
      WHEN {% condition selected_category %} '' {% endcondition %}
        AND {% condition selected_brand %} '' {% endcondition %}
      THEN ${category}
      
      WHEN {% condition selected_category %} ${category} {% endcondition %} 
        AND {% condition selected_brand %} '' {% endcondition %}
      THEN ${brand}
      
      WHEN {% condition selected_category %} '' {% endcondition %} 
        AND {% condition selected_brand %} ${brand} {% endcondition %}
      THEN ${item_name}
      
      WHEN {% condition selected_category %} ${category} {% endcondition %} 
        AND {% condition selected_brand %} ${brand} {% endcondition %}
      THEN ${item_name}
      
      END
  
    
######## Measures ########

  - measure: count
    type: count
    drill_fields: [id, item_name, inventory_items.count]

