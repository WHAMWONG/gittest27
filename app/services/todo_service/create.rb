
module TodoService
  require 'validators/unique_title_validator'
  class Create
    include ActiveModel::Model
    include ActiveModel::Validations

    validates :user_id, presence: true
    validates :title, presence: { message: "The title is required." }, length: { maximum: 1000, too_long: "The title cannot exceed 1000 characters." }, unique_title: true
    validates :due_date, presence: true, datetime_in_future: true
    validate :validate_recurrence, if: -> { is_recurring && recurrence.present? }
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
      return { status: :unprocessable_entity, errors: errors.full_messages } unless valid?

      user = User.find_by(id: @user_id)
      return { status: :not_found, error: 'The User not found.' } unless user

      todo = user.todos.create!(
        title: @title,
        description: @description,
        due_date: @due_date.in_time_zone,
        priority: @priority,
        is_recurring: @is_recurring,
        recurrence: @recurrence,
        category_id: @category_id
      )

      associate_categories(todo) if @category_ids.present?
      attach_files(todo) if @attachments.present?

      { status: :created, todo_id: todo.id }
    rescue ActiveRecord::RecordInvalid => e
      { status: :unprocessable_entity, errors: e.record.errors.full_messages }
    end

    private

    attr_reader :user_id, :title, :description, :due_date, :priority, :is_recurring, :recurrence, :category_ids, :attachments

    def validate_recurrence
      errors.add(:recurrence, 'Invalid recurrence type.') unless Todo.recurrences.keys.include?(@recurrence)
    end

    def validate_user
      errors.add(:user_id, 'User not found.') unless User.exists?(@user_id)
    end

    def validate_category_id
      if @category_id && !Category.exists?(@category_id)
        errors.add(:category_id, 'Category not found.')
      end
    end

    def validate_priority # Ensure priority is within the defined enum values
      errors.add(:priority, "Invalid priority level.") unless Todo.priorities.keys.include?(@priority)
    end

    def associate_categories(todo) # Create associations in the "todo_categories" table
      @category_ids.each do |category_id|
        if Category.exists?(category_id)
          todo.todo_categories.create!(category_id: category_id)
        end
      end
    end

    def attach_files(todo) # Process and attach files to the todo
      @attachments.each do |attachment|
        if valid_attachment?(attachment)
          todo.attachments.create!(file: attachment)
        end
      end
    end

    def valid_attachment?(attachment) # Validate attachment format and size
      # Implement validation logic here
      true # Placeholder return value
    end
  end
end
