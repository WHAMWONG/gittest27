# frozen_string_literal: true

class UniqueTitleValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if Todo.where(user_id: record.user_id).exists?(title: value)
      record.errors.add(attribute, 'has already been taken')
    end
  end
end

# In the Todo model (/app/models/todo.rb), import this validator:
# validates :title, unique_title: true, length: { maximum: 10 }
