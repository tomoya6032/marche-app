class GenerateImageVariantsJob < ApplicationJob
  queue_as :default

  # args: model_name (String), record_id (Integer), attachment_name (String), variants (Array of Hash)
  def perform(model_name, record_id, attachment_name, variants = [])
    model = model_name.constantize
    record = model.find_by(id: record_id)
    return unless record

    attachment = record.public_send(attachment_name)
    return unless attachment.attached?

    if attachment.respond_to?(:each)
      # has_many_attached
      attachment.each do |blob|
        generate_variants_for_blob(blob, variants)
      end
    else
      # has_one_attached
      generate_variants_for_blob(attachment, variants)
    end
  rescue => e
    Rails.logger.error "GenerateImageVariantsJob error for #{model_name}##{record_id} #{attachment_name}: #{e.class} #{e.message}\n#{e.backtrace.first(5).join("\n")}" 
  end

  private

  def generate_variants_for_blob(blob, variants)
    variants.each do |variant_opts|
      # variant_opts expected like { resize_to_limit: [800,600] }
      begin
        blob.variant(variant_opts).processed
      rescue => e
        Rails.logger.error "Variant generation failed for blob id=#{blob.id} opts=#{variant_opts.inspect}: #{e.class} #{e.message}"
      end
    end
  end
end
