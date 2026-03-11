class ReportPdf
  def initialize(report)
    @report = report
  end

  def generate
    pdf = Prawn::Document.new

    pdf.text "Hazard Report ##{@report.id}", size: 24, style: :bold
    pdf.move_down 10
    pdf.stroke_horizontal_rule
    pdf.move_down 20

    details = [
      [ "Title", @report.title ],
      [ "Severity", @report.severity.titleize ],
      [ "Status", @report.status.titleize ],
      [ "Location", @report.location ],
      [ "Reporter", @report.reporter.full_name ],
      [ "Assignee", @report.assignee&.full_name || "Unassigned" ],
      [ "Reported At", @report.reported_at.strftime("%B %d, %Y %H:%M") ],
      [ "Created At", @report.created_at.strftime("%B %d, %Y %H:%M") ]
    ]

    pdf.table(details, width: pdf.bounds.width) do
      column(0).font_style = :bold
      column(0).width = 120
      cells.padding = [ 5, 10 ]
      cells.borders = [ :bottom ]
      cells.border_color = "CCCCCC"
    end

    pdf.move_down 20
    pdf.text "Description", size: 14, style: :bold
    pdf.move_down 5
    pdf.text @report.description

    if @report.comments.any?
      pdf.move_down 20
      pdf.text "Comments", size: 14, style: :bold
      pdf.move_down 5

      @report.comments.includes(:user).each do |comment|
        pdf.text "#{comment.user.full_name} (#{comment.created_at.strftime('%B %d, %Y %H:%M')}):", style: :bold, size: 10
        pdf.text comment.body, size: 10
        pdf.move_down 5
      end
    end

    pdf.move_down 20
    pdf.text "Generated on #{Time.current.strftime('%B %d, %Y %H:%M')}", size: 8, color: "999999"

    pdf.render
  end
end
