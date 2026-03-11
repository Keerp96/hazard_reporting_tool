class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_report

  def create
    @comment = @report.comments.build(comment_params)
    @comment.user = current_user
    authorize @comment

    if @comment.save
      HazardMailer.comment_notification(@comment).deliver_later
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @report, notice: "Comment added." }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("comment_form", partial: "comments/form", locals: { report: @report, comment: @comment }) }
        format.html { redirect_to @report, alert: "Comment could not be added." }
      end
    end
  end

  def destroy
    @comment = @report.comments.find(params[:id])
    authorize @comment
    @comment.destroy

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@comment) }
      format.html { redirect_to @report, notice: "Comment deleted." }
    end
  end

  private

  def set_report
    @report = Report.find(params[:report_id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
