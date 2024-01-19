
json.status 201
json.todo do
  json.id @todo.id
  json.user_id @todo.user_id
  json.title @todo.title
  json.description @todo.description if @todo.description.present?
  json.due_date @todo.due_date.iso8601
  json.priority @todo.priority
  json.is_recurring @todo.is_recurring if @todo.is_recurring.present?
  json.recurrence @todo.recurrence if @todo.recurrence.present?
  json.category_id @todo.category_id if @todo.category_id.present?
end
