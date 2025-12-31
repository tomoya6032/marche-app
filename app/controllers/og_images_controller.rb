class OgImagesController < ApplicationController
  # Serve dynamically-generated OGP images for selected pages.
  # The endpoint is GET /og_images/:page.jpg
  # Allowed pages are restricted in routes constraints.
  def show
    page = params[:page].to_s
    generator = OgImageGenerator.new(page)
    image_data = generator.generate

    send_data image_data,
              type: 'image/jpeg',
              disposition: 'inline',
              filename: "#{page}.jpg",
              status: :ok
  rescue StandardError => e
    Rails.logger.error("OG image generation failed for=#{params[:page]}: #{e.message}\n#{e.backtrace.join("\n")}" )
    head :not_found
  end
end
