class LocationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @locations = Location.all
  end

  def qr_code
    @location = Location.find(params[:id])
    qr_url = new_report_url(location: @location.code)
    qr = RQRCode::QRCode.new(qr_url)
    @svg = qr.as_svg(
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 4,
      standalone: true,
      use_path: true
    )

    respond_to do |format|
      format.html
      format.svg { render inline: @svg, content_type: "image/svg+xml" }
    end
  end
end
