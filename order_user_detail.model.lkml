connection: "thelook"

# include the restricted model
include: "orders.model"

explore: order_items_detail {
  from:  order_items
  extends: [order_items]

  # join: users {
  #   from: users_detail
  #   view_label: "Users"
  #   type: left_outer
  #   sql_on: ${users.id} = ${order_facts.user_id};;
  #   relationship: many_to_one
  # }
}
