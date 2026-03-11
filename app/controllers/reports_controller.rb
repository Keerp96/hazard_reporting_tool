require "csv"

class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_report, only: [ :show, :edit, :update, :destroy, :assign, :start_work, :resolve, :close, :reopen, :download_pdf ]

  def index
    @q = policy_scope(Report).ransack(params[:q])
    @q.sorts = "reported_at desc" if @q.sorts.empty?
    @reports = @q.result(distinct: true).includes(:reporter, :assignee).page(params[:page]).per(10)
    @locations = Location.all
  end

  def show
    authorize @report
    @comment = Comment.new
    @comments = @report.comments.includes(:user)
  end

  def new
    @report = Report.new(reported_at: Time.current)
    @report.location = params[:location] if params[:location].present?
    authorize @report
    @locations = Location.all
  end

  def create
    @report = current_user.reported_hazards.build(report_params)
    authorize @report

    if @report.save
      HazardMailer.new_report_notification(@report).deliver_later
      redirect_to @report, notice: "Hazard report was successfully created."
    else
      @locations = Location.all
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @report
    @locations = Location.all
  end

  def update
    authorize @report

    if @report.update(report_params)
      redirect_to @report, notice: "Hazard report was successfully updated."
    else
      @locations = Location.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @report
    @report.destroy
    redirect_to reports_url, notice: "Hazard report was successfully deleted."
  end

  def assign
    authorize @report, :assign?
    assignee = User.find(params[:assignee_id])
    @report.assignee = assignee

    if @report.may_assign? && @report.assign!
      HazardMailer.assignment_notification(@report).deliver_later
      redirect_to @report, notice: "Report assigned to #{assignee.full_name}."
    else
      redirect_to @report, alert: "Cannot assign this report."
    end
  end

  def start_work
    authorize @report, :update?
    if @report.may_start_work? && @report.start_work!
      redirect_to @report, notice: "Work started on this report."
    else
      redirect_to @report, alert: "Cannot start work on this report."
    end
  end

  def resolve
    authorize @report, :resolve?
    if @report.may_resolve? && @report.resolve!
      HazardMailer.resolution_notification(@report).deliver_later
      redirect_to @report, notice: "Report marked as resolved."
    else
      redirect_to @report, alert: "Cannot resolve this report."
    end
  end

  def close
    authorize @report, :update?
    if @report.may_close? && @report.close!
      redirect_to @report, notice: "Report closed."
    else
      redirect_to @report, alert: "Cannot close this report."
    end
  end

  def reopen
    authorize @report, :update?
    if @report.may_reopen? && @report.reopen!
      redirect_to @report, notice: "Report reopened."
    else
      redirect_to @report, alert: "Cannot reopen this report."
    end
  end

  def export_csv
    authorize Report, :export?
    @reports = policy_scope(Report).includes(:reporter, :assignee)

    csv_data = CSV.generate(headers: true) do |csv|
      csv << [ "ID", "Title", "Description", "Location", "Severity", "Status", "Reporter", "Assignee", "Reported At", "Created At" ]
      @reports.find_each do |report|
        csv << [
          report.id,
          report.title,
          report.description,
          report.location,
          report.severity.titleize,
          report.status.titleize,
          report.reporter.full_name,
          report.assignee&.full_name || "Unassigned",
          report.reported_at.strftime("%Y-%m-%d %H:%M"),
          report.created_at.strftime("%Y-%m-%d %H:%M")
        ]
      end
    end

    send_data csv_data, filename: "hazard_reports_#{Date.current}.csv", type: "text/csv"
  end

  def download_pdf
    authorize @report, :show?
    pdf = ReportPdf.new(@report).generate
    send_data pdf, filename: "hazard_report_#{@report.id}.pdf", type: "application/pdf", disposition: "attachment"
  end

  private

  def set_report
    @report = Report.find(params[:id])
  end

  def report_params
    params.require(:report).permit(:title, :description, :location, :severity, :reported_at, :photo)
  end
end
