class TodoPolicy < ApplicationPolicy
  attr_reader :user, :todo

  def initialize(user, todo)
    @user = user
    @todo = todo
  end

  def assign_category?
    user.is_a?(User) && todo.user_id == user.id
  end
end
