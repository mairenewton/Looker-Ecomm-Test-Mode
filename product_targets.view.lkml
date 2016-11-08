view: product_targets {
  derived_table: {
    sql: SELECT
         CONCAT(inventory_items.product_id, inventory_items.sold_at) AS id
        ,inventory_items.product_id
        ,inventory_items.sold_at AS target_date
        ,SUM(inventory_items.cost*(ROUND((RAND()*(107-90))+90)/100)) AS target_product_cost
        ,SUM(order_items.sale_price*(ROUND((RAND()*(107-90))+90)/100)) AS target_product_price
      FROM order_items
      LEFT JOIN inventory_items
      ON order_items.inventory_item_id = inventory_items.id
      GROUP BY 1, 2
       ;;
    sql_trigger_value: SELECT MAX(inventory_items.product_id) ;;
    indexes: ["product_id"]
  }

  ######## Dimensions ########

  dimension: id {
    type: number
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.id ;;
  }

  dimension: product_id {
    type: number
    hidden: yes
    sql: ${TABLE}.product_id ;;
  }

  dimension_group: target {
    type: time
    timeframes: [month, year]
    sql: ${TABLE}.target_date ;;
  }

  dimension: target_product_cost {
    type: number
    hidden: yes
    sql: ${TABLE}.target_product_cost ;;
    value_format_name: usd
  }

  dimension: target_product_sale_price {
    type: number
    hidden: yes
    sql: ${TABLE}.target_product_price ;;
    value_format_name: usd
  }

  ######## Measures ########

  measure: total_target_product_cost {
    type: sum
    sql: ${target_product_cost} ;;
    value_format_name: usd
  }

  measure: total_target_product_revenue {
    type: sum
    sql: ${target_product_sale_price} ;;
    value_format_name: usd
  }
}
