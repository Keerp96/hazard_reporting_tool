class CommentPolicy < ApplicationPolicy
  def create?
    true
  end

  def destroy?
    user.supervisor? || record.user_id == user.id
  end
end
