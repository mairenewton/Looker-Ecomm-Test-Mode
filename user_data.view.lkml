view: user_data {
  sql_table_name: demo_db.user_data ;;
  ######## Dimensions ########

  dimension: id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: max_num_orders {
    type: number
    hidden: yes
    sql: ${TABLE}.max_num_orders ;;
  }

  dimension: total_num_orders {
    type: number
    hidden: yes
    sql: ${TABLE}.total_num_orders ;;
  }

  dimension: user_id {
    type: number
    hidden: yes
    sql: ${TABLE}.user_id ;;
  }

  dimension: repeat_customer_flag {
    type: yesno
    sql: ${total_num_orders} > 1 ;;
  }

  ######## Measures ########

  measure: count {
    type: count
    hidden: yes
    drill_fields: [id, users.last_name, users.first_name, users.id]
  }

  measure: total_repeat_customers {
    type: count

    filters: {
      field: repeat_customer_flag
      value: "true"
    }
  }

  measure: percent_repeat_customers {
    type: number
    sql: 1*${total_repeat_customers}/${count} ;;
    value_format_name: percent_1
  }

  measure: first_order_date {
    type: date
    sql: DATE(MIN(${order_facts.created_date})) ;;
    convert_tz: no
  }
}
