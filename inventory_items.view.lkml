view: inventory_items {
  sql_table_name: demo_db.inventory_items ;;
  ######## Dimensions ########

  dimension: id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: cost {
    type: number
    sql: ${TABLE}.cost ;;
  }

  dimension: product_id {
    type: number
    hidden: yes
    sql: ${TABLE}.product_id ;;
  }

  ######## Time Dimensions ########

  dimension_group: created {
    type: time
    description: "date in which a product was entered into inventory"
    timeframes: [date, week, month, year]
    sql: ${TABLE}.created_at ;;
  }

  dimension_group: sold {
    type: time
    description: "date in which a product was released from inventory"
    timeframes: [date, week, month, year]
    sql: ${TABLE}.sold_at ;;
  }

  dimension: inventory_age {
    type: number
    description: "number of days in which a product remained in inventory"
    sql: datediff(IFNULL(${sold_date}, 0), ${created_date}) ;;
  }

  ######## Measures ########

  measure: count {
    type: count
    drill_fields: [id, products.item_name, products.id, order_items.count]
  }

  measure: total_cost {
    type: sum
    sql: ${cost} ;;
    value_format_name: usd
  }

  measure: total_inventory_age {
    type: sum
    sql: ${inventory_age} ;;
    value_format_name: decimal_0
  }

  measure: average_inventory_age {
    type: average
    sql: ${inventory_age} ;;
    value_format_name: decimal_0
  }
}
