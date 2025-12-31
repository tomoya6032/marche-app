require 'image_processing/mini_magick'

class OgImageGenerator
  WIDTH = 1200
  HEIGHT = 630

  MAPPING = {
    'features' => 'Image-of-function.png',
    'pricing' => 'pricing/hero.jpg',
    'plan_comparison' => 'plan_comparison/hero.jpg'
  }.freeze

  def initialize(page)
    @page = page.to_s
  end

  # Returns binary JPEG data (String)
  def generate
    src = source_image_path
    raise "source image not found" unless src && File.exist?(src)

    pipeline = ImageProcessing::MiniMagick.source(src)
    processed = pipeline.resize_to_fill(WIDTH, HEIGHT, gravity: 'Center').convert('jpg').call

    data = File.binread(processed.path)
    processed.unlink if processed.respond_to?(:unlink)
    data
  end

  private

  def source_image_path
    candidate = MAPPING[@page]
    return nil unless candidate

    path = Rails.root.join('app', 'assets', 'images', candidate)
    return path.to_s if File.exist?(path)

    # fallback: features image
    fallback = Rails.root.join('app', 'assets', 'images', 'Image-of-function.png')
    return fallback.to_s if File.exist?(fallback)

    # final fallback: site icon
    final = Rails.root.join('app', 'assets', 'images', 'marchelogo2.png')
    return final.to_s if File.exist?(final)

    nil
  end
end
