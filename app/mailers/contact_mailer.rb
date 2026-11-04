class ContactMailer < ApplicationMailer
  default from: -> { SiteSetting.contact_email }

  def contact_notification(contact)
    @contact = contact
    @recipient_email = SiteSetting.contact_email

    mail(
      to: @recipient_email,
      subject: "[お問い合わせ] #{@contact.subject.presence || '件名未記入'}"
    )
  end

  def auto_reply(contact)
    @contact = contact

    mail(
      to: @contact.email,
      subject: "[自動返信] お問い合わせを受け付けました"
    )
  end
end
