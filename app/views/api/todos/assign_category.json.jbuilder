json.status 201
json.todo_category do
  json.todo_id @todo_category.todo_id
  json.category_id @todo_category.category_id
end
