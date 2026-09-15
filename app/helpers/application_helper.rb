module ApplicationHelper
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
end
