namespace :active_storage do
  desc 'Enqueue variant generation jobs for common attachments'
  task generate_variants: :environment do
    # Define which models/attachments and which variants to generate
    targets = [
      { model: 'Event', attachments: [:images], variants: [{ resize_to_limit: [800, 600] }, { resize_to_limit: [1200, 630] }] },
      { model: 'Host', attachments: [:top_image, :goods_image_1, :goods_image_2, :goods_image_3, :goods_image_4, :images], variants: [{ resize_to_limit: [800, 600] }] },
      { model: 'Seller', attachments: [:image, :images], variants: [{ resize_to_limit: [800, 600] }] },
      { model: 'Good', attachments: [:image], variants: [{ resize_to_limit: [800, 600] }] }
    ]

    targets.each do |t|
      model = t[:model].constantize
      model.find_each do |record|
        t[:attachments].each do |attachment_name|
          if record.respond_to?(attachment_name)
            puts "Enqueue variants for #{t[:model]} id=#{record.id} attachment=#{attachment_name}"
            GenerateImageVariantsJob.perform_later(t[:model], record.id, attachment_name.to_s, t[:variants])
          end
        end
      end
    end
    puts 'Enqueued variant generation jobs.'
  end
end
