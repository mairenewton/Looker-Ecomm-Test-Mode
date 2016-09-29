- connection: thelook

- include: "orders.model.lookml"       # include the restricted model


- explore: order_items_detail
  extends: order_items
  joins:
    - join: users
      from: users_detail
      view_label: Users
      type: left_outer 
      sql_on: ${order_facts.user_id} = ${users.id}
      relationship: many_to_one
