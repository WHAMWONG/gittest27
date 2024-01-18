
module TodoService
  require 'validators/datetime_in_future_validator'
  class Create
    include ActiveModel::Model
    include ActiveModel::Validations

    validates :user_id, presence: true
    validates :title, presence: true, length: { maximum: 255 }
    validates :due_date, presence: true, datetime_in_future: true
    validate :validate_recurrence, if: -> { is_recurring }
    validate :validate_category_ids, if: -> { category_ids.present? }
    validate :validate_attachments, if: -> { attachments.present? }
    validate :validate_priority, :validate_user, :validate_category_id

    def initialize(user_id:, title:, description: nil, due_date:, priority:, is_recurring: false, recurrence: nil, category_ids: [], attachments: [], category_id: nil)
      @user_id = user_id
      @title = title
      @description = description
      @due_date = due_date
      @priority = priority
      @is_recurring = is_recurring
      @recurrence = recurrence
      @category_ids = category_ids
      @category_id = category_id
      @attachments = attachments
    end

    def call
      return errors.full_messages unless valid?

      user = User.find_by(id: @user_id)
      return 'User not found.' unless user

      todo = user.todos.create!(
        title: @title,
        description: @description,
        due_date: @due_date,
        priority: @priority,
        is_recurring: @is_recurring,
        recurrence: @recurrence,
        category_id: @category_id
      )

      associate_categories(todo) if @category_ids.present?
      attach_files(todo) if @attachments.present?

      { todo_id: todo.id }
    rescue ActiveRecord::RecordInvalid => e
      e.record.errors.full_messages
    end

    private

    attr_reader :user_id, :title, :description, :due_date, :priority, :is_recurring, :recurrence, :category_ids, :attachments, :category_id

    def validate_recurrence
      errors.add(:recurrence, I18n.t('activerecord.errors.messages.invalid')) unless Todo.recurrences.keys.include?(@recurrence)
    end

    def validate_user
      errors.add(:user_id, 'User not found.') unless User.exists?(@user_id)
    end

    def validate_category_id
      if @category_id.present? && !Category.exists?(@category_id)
        errors.add(:category_id, 'Category not found.')
      end
    end

    def validate_priority
      errors.add(:priority, "Invalid priority level.") unless Todo.priorities.keys.include?(@priority)
    end

    def validate_attachments
      # Placeholder for attachment validation logic
    end

    def associate_categories(todo)
      @category_ids.each do |category_id|
        todo.todo_categories.create!(category_id: category_id)
      end
    end

    def attach_files(todo)
      @attachments.each do |attachment|
        # Placeholder for file processing and attachment logic
        todo.attachments.create!(file: attachment)
      end
    end
  end
end
