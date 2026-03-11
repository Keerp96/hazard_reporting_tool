class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  enum :role, { employee: 0, supervisor: 1 }

  has_many :reported_hazards, class_name: "Report", foreign_key: :reporter_id, dependent: :nullify, inverse_of: :reporter
  has_many :assigned_hazards, class_name: "Report", foreign_key: :assignee_id, dependent: :nullify, inverse_of: :assignee
  has_many :comments, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true

  def full_name
    "#{first_name} #{last_name}"
  end
end
