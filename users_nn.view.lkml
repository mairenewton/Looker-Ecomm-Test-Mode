view: users_nn {
  label: "Users"
  sql_table_name: demo_db.usersNN ;;
  ######## Dimensions ########

  dimension: id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}.first_name ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}.last_name ;;
  }

  ######## Measures ########

  measure: count {
    type: count
    drill_fields: [id, first_name, last_name]
  }
}
