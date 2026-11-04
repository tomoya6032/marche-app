class ContactsController < ApplicationController
  def new
    @contact_form = ContactForm.new
  end

  def create
    @contact_form = ContactForm.new(contact_params)

    if @contact_form.valid?
      ContactMailer.contact_notification(@contact_form).deliver_later
      ContactMailer.auto_reply(@contact_form).deliver_later

      redirect_to new_contact_path, notice: "お問い合わせを送信しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def contact_params
    params.require(:contact_form).permit(:name, :email, :subject, :message)
  end
end
