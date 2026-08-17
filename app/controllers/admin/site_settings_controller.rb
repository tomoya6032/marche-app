class Admin::SiteSettingsController < Admin::BaseController
  before_action :authenticate_administrator!
  before_action :set_site_setting

  def edit
    # 設定画面の表示
  end

  def update
    if @site_setting.update(site_setting_params)
      redirect_to edit_admin_site_setting_path, notice: "サイト設定が更新されました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_site_setting
    @site_setting = SiteSetting.instance
  end

  def site_setting_params
    params.require(:site_setting).permit(:contact_email)
  end
end
