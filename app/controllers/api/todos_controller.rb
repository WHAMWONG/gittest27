module Api
  class TodosController < BaseController
    before_action :doorkeeper_authorize!

    def attach_file
      todo = Todo.find_by(id: params[:todo_id])
      return render json: { message: "Todo item not found." }, status: :not_found unless todo

      unless params[:file].present?
        return render json: { message: "File is required." }, status: :bad_request
      end

      begin
        attachment = todo.attachments.create!(file: params[:file])
        render json: {
          status: 201,
          attachment: {
            id: attachment.id,
            todo_id: attachment.todo_id,
            file: attachment.file
          }
        }, status: :created
      rescue => e
        render json: { message: e.message }, status: :unprocessable_entity
      end
    end

    def assign_category
      todo_id = params[:todo_id]
      category_id = params.require(:category).permit(:category_id)[:category_id]

      todo = Todo.find_by(id: todo_id)
      return render json: { error: "Todo item not found." }, status: :not_found unless todo

      unless Category.exists?(category_id)
        return render json: { error: "Category not found." }, status: :not_found
      end

      begin
        todo_category = todo.todo_categories.create!(category_id: category_id)
        render json: { status: 201, todo_category: { todo_id: todo_category.todo_id, category_id: todo_category.category_id } }, status: :created
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def todo_category_params
      params.require(:todo_category).permit(:todo_id, :category_id)
    end
  end
end
