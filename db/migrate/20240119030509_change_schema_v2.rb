class ChangeSchemaV2 < ActiveRecord::Migration[6.0]
  def change
    remove_reference :todo_categories, :todo, foreign_key: true if foreign_key_exists?(:todo_categories, :todos)
    remove_reference :todos, :user, foreign_key: true if foreign_key_exists?(:todos, :users)
    remove_reference :attachments, :todo, foreign_key: true if foreign_key_exists?(:attachments, :todos)
    if foreign_key_exists?(:todo_categories, :categories)
      remove_reference :todo_categories, :category, foreign_key: true
    end
    drop_table :todos
    drop_table :users
    drop_table :attachments
    drop_table :categories
    drop_table :todo_categories
  end
end
