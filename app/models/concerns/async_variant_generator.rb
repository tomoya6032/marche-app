module AsyncVariantGenerator
  extend ActiveSupport::Concern

  included do
    after_commit :enqueue_variants_for_attached_images, on: [:create, :update]
  end

  DEFAULT_VARIANTS = [{ resize_to_limit: [800, 600] }, { resize_to_limit: [1200, 630] }]

  private

  def enqueue_variants_for_attached_images
    attachment_names = if defined?(self.class::VARIANT_ATTACHMENT_NAMES)
                         self.class::VARIANT_ATTACHMENT_NAMES
                       else
                         []
                       end

    variants = if defined?(self.class::VARIANT_COMMON_VARIANTS)
                 self.class::VARIANT_COMMON_VARIANTS
               else
                 DEFAULT_VARIANTS
               end

    attachment_names.each do |att_name|
      next unless respond_to?(att_name)
      att = public_send(att_name)
      next unless att.attached?

      # Enqueue job to generate variants
      GenerateImageVariantsJob.perform_later(self.class.name, id, att_name.to_s, variants)
    end
  end
end
