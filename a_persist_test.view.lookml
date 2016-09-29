- view: a_persist_test
  derived_table:
    sql: |
      SELECT
         id
        ,ROUND(RAND()*(100-1)+1) AS random_number
      FROM demo_db.products
      GROUP BY 1
    persist_for: 5 minutes
    indexes: [id]

  fields:
  
  - dimension: id
    type: number
    primary_key: true
    sql: ${TABLE}.id
    
  - dimension: random
    type: number
    sql: ${TABLE}.random_number
    
  - measure: count
    type: count
    
  - measure: total_random
    type: sum
    sql: ${random}

