module ApplicationHelper
  def default_og_image_url
    absolute_url(asset_path("marchelogo2.png"))
  end

  def shop_og_image_url(resource)
    attachment = if resource.respond_to?(:images) && resource.images.attached?
      resource.images.first
    elsif resource.respond_to?(:top_image) && resource.top_image.attached?
      resource.top_image
    end

    return default_og_image_url unless attachment

    absolute_url(rails_storage_proxy_path(attachment))
  rescue StandardError
    default_og_image_url
  end

  def shop_og_description(resource)
    resource.try(:description).presence || "つながるマルシェのショップ詳細ページです。"
  end

  def admin_last_login_label(resource)
    return resource.last_active_label if resource.respond_to?(:last_active_label)

    last_login_at = resource.try(:last_sign_in_at)
    return "記録なし" if last_login_at.blank?

    days = (Date.today - last_login_at.to_date).to_i
    return "本日" if days.zero?

    "#{days}日前 (#{last_login_at.strftime('%Y/%m/%d')})"
  end

  def admin_last_login_class(resource)
    return resource.last_active_status_class if resource.respond_to?(:last_active_status_class)

    last_login_at = resource.try(:last_sign_in_at)
    return "login-never" if last_login_at.blank?

    days = (Date.today - last_login_at.to_date).to_i
    return "login-stale" if days >= 180
    return "login-warning" if days >= 90

    "login-recent"
  end

  def absolute_url(path_or_url)
    value = path_or_url.to_s
    return value if value.start_with?("http://", "https://")

    base = request_base_url
    return value if base.blank?

    path = value.start_with?("/") ? value : "/#{value}"
    "#{base}#{path}"
  end

  def normalize_breadcrumb_path(path)
    return "#" if path.blank?

    parsed = URI.parse(path.to_s)
    normalized = parsed.path.presence || "/"
    normalized += "?#{parsed.query}" if parsed.query.present?
    normalized += "##{parsed.fragment}" if parsed.fragment.present?
    normalized
  rescue URI::InvalidURIError
    path
  end

  def breadcrumb_html
    return '' unless defined?(breadcrumb) && breadcrumb.present?
    
    content_tag(:nav, class: 'breadcrumbs', aria: { label: 'パンくずリスト' }) do
      content_tag(:ol, class: 'breadcrumb-list') do
        breadcrumb.map.with_index do |crumb, index|
          content_tag(:li, class: 'breadcrumb-item') do
            if index == breadcrumb.size - 1
              content_tag(:span, crumb.text, class: 'breadcrumb-current')
            else
              link_to(crumb.text, crumb.url, class: 'breadcrumb-link')
            end
          end
        end.join.html_safe
      end
    end
  end

  private

  def request_base_url
    if respond_to?(:request) && request.present?
      request.base_url
    else
      defaults = Rails.application.config.action_controller.default_url_options || {}
      host = defaults[:host].presence || ENV["APP_HOST"].presence
      return nil if host.blank?

      protocol = defaults[:protocol].presence || "https"
      "#{protocol}://#{host}"
    end
  end
end
