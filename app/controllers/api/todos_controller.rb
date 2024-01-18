class Api::TodosController < Api::BaseController
  before_action :doorkeeper_authorize!

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
