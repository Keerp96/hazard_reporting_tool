class Report < ApplicationRecord
  include AASM

  belongs_to :reporter, class_name: "User", inverse_of: :reported_hazards
  belongs_to :assignee, class_name: "User", optional: true, inverse_of: :assigned_hazards
  has_many :comments, dependent: :destroy

  has_one_attached :photo

  enum :severity, { low: 0, medium: 1, high: 2, critical: 3 }
  enum :status, { open: 0, assigned: 1, in_progress: 2, resolved: 3, closed: 4 }

  validates :title, presence: true, length: { maximum: 200 }
  validates :description, presence: true
  validates :location, presence: true
  validates :severity, presence: true
  validates :reported_at, presence: true
  validates :photo, content_type: [ "image/png", "image/jpeg", "image/webp" ],
                    size: { less_than: 5.megabytes, message: "must be less than 5MB" },
                    if: -> { photo.attached? }

  scope :open_reports, -> { where(status: [ :open, :assigned, :in_progress ]) }
  scope :resolved_reports, -> { where(status: [ :resolved, :closed ]) }
  scope :by_severity, -> { group(:severity).count }
  scope :by_location, -> { group(:location).count }
  scope :recent, -> { order(reported_at: :desc) }
  scope :this_month, -> { where(reported_at: Time.current.beginning_of_month..Time.current.end_of_month) }

  def self.ransackable_attributes(_auth_object = nil)
    %w[title description location severity status reported_at created_at reporter_id assignee_id]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[reporter assignee comments]
  end

  def self.open_count
    open_reports.count
  end

  def self.resolution_rate_this_month
    month_reports = this_month
    return 0 if month_reports.count.zero?
    (month_reports.resolved_reports.count.to_f / month_reports.count * 100).round(1)
  end

  def self.traffic_light
    count = open_count
    if count < 5
      :green
    elsif count <= 10
      :yellow
    else
      :red
    end
  end

  aasm column: :status, enum: true do
    state :open, initial: true
    state :assigned
    state :in_progress
    state :resolved
    state :closed

    event :assign do
      transitions from: :open, to: :assigned, guard: :assignee_present?
    end

    event :start_work do
      transitions from: :assigned, to: :in_progress
    end

    event :resolve do
      transitions from: [ :assigned, :in_progress ], to: :resolved
    end

    event :close do
      transitions from: :resolved, to: :closed
    end

    event :reopen do
      transitions from: [ :resolved, :closed ], to: :open
      after do
        self.assignee = nil
      end
    end
  end

  def assignee_present?
    assignee.present?
  end

  def severity_color
    case severity
    when "low" then "success"
    when "medium" then "warning"
    when "high" then "orange"
    when "critical" then "danger"
    else "secondary"
    end
  end

  def status_color
    case status
    when "open" then "primary"
    when "assigned" then "info"
    when "in_progress" then "warning"
    when "resolved" then "success"
    when "closed" then "secondary"
    else "light"
    end
  end
end

