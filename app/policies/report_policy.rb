class ReportPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    user.supervisor? || record.reporter_id == user.id
  end

  def create?
    true
  end

  def update?
    user.supervisor?
  end

  def destroy?
    user.supervisor?
  end

  def assign?
    user.supervisor?
  end

  def resolve?
    user.supervisor?
  end

  def export?
    true
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.supervisor?
        scope.all
      else
        scope.where(reporter_id: user.id)
      end
    end
  end
end
