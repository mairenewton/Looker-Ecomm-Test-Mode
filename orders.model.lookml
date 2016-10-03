- connection: thelook

- include: "*.view.lookml"        # include order_items view

- include: "*.dashboard.lookml"             # include all the dashboards

######## Inventory Items Explore ########

- explore: inventory_items
  joins:
    - join: products
      type: left_outer 
      sql_on: ${inventory_items.product_id} = ${products.id}
      relationship: many_to_one

######## Orders Explore ########

- explore: order_items
#   fields: [ALL_FIELDS*, -order_items.count_of_women]
  sql_always_where: ${users.id} != 1       #### Remove test user from data ####
#   always_filter: 
#     order_facts.is_before_mtd: true
  conditionally_filter:
    order_facts.created_year: 'this year'
    unless: [order_facts.created_year, order_facts.created_month, order_facts.created_week, order_facts.created_date]
  persist_for: 4 hours
  view: order_items
  from: order_items
  joins:
    - join: inventory_items
      type: left_outer 
      sql_on: ${order_items.inventory_item_id} = ${inventory_items.id}
      relationship: one_to_one
      
    - join: order_facts
      view_label: Orders
      type: left_outer
      sql_on: ${order_items.order_id} = ${order_facts.id}
      relationship: many_to_one

    - join: users
      from: users_detail
      type: left_outer 
      sql_on: ${order_facts.user_id} = ${users.id}
      relationship: many_to_one
      
    - join: user_facts
      type: left_outer
      sql_on: ${order_facts.user_id} = ${user_facts.id}
      relationship: many_to_one
      
    - join: user_data
      view_label: Users
      type: inner
      sql_on: ${users.id} = ${user_data.user_id}
      relationship: one_to_one
      
    - join: product_targets
      view_label: Products
      type: left_outer
      sql_on: ${inventory_items.product_id} = ${product_targets.product_id} AND
              ${order_facts.created_month} = ${product_targets.target_month}
      relationship: many_to_one

    - join: products
      type: left_outer 
      sql_on: ${inventory_items.product_id} = ${products.id}
      relationship: many_to_one

######## Order Items Detail Data Explore with Added User Information ########

- explore: product_targets
  joins:
    - join: products
      type: left_outer
      sql_on: ${product_targets.product_id} = ${products.id}
      relationship: many_to_one

# - explore: order_items_detail
#   extends: order_items
#   joins:
#     - join: users_detail
#       type: left_outer 
#       sql_on: ${order_facts.user_id} = ${users_detail.id}
#       relationship: many_to_one


