module TodoService
  class Create
    include ActiveModel::Validations

    validates :user_id, presence: true
    validates :title, presence: true
    validates :due_date, presence: true, datetime_in_future: true
    validate :validate_recurrence, if: -> { is_recurring }
    validate :validate_category_ids, if: -> { category_ids.present? }
    validate :validate_attachments, if: -> { attachments.present? }

    def initialize(user_id:, title:, description: nil, due_date:, priority:, is_recurring: false, recurrence: nil, category_ids: [], attachments: [])
      @user_id = user_id
      @title = title
      @description = description
      @due_date = due_date
      @priority = priority
      @is_recurring = is_recurring
      @recurrence = recurrence
      @category_ids = category_ids
      @attachments = attachments
    end

    def call
      return errors.full_messages unless valid?

      user = User.find_by(id: @user_id)
      return I18n.t('activerecord.errors.messages.invalid') unless user

      todo = user.todos.create!(
        title: @title,
        description: @description,
        due_date: @due_date,
        priority: @priority,
        is_recurring: @is_recurring,
        recurrence: @recurrence
      )

      associate_categories(todo) if @category_ids.present?
      attach_files(todo) if @attachments.present?

      { todo_id: todo.id }
    rescue ActiveRecord::RecordInvalid => e
      e.record.errors.full_messages
    end

    private

    attr_reader :user_id, :title, :description, :due_date, :priority, :is_recurring, :recurrence, :category_ids, :attachments

    def validate_recurrence
      errors.add(:recurrence, I18n.t('activerecord.errors.messages.invalid')) unless Todo.recurrences.keys.include?(@recurrence)
    end

    def validate_category_ids
      @category_ids.each do |category_id|
        errors.add(:category_ids, I18n.t('activerecord.errors.messages.invalid')) unless Category.exists?(category_id)
      end
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
