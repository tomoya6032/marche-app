class FacilitiesController < ApplicationController
  def index
    @breadcrumbs = [{name: "ホーム", path: root_path}, {name: "出店一覧", path: facilities_path}]
    @facilities = Facility.all
    # 管理画面で一覧除外されたアカウントは公開一覧に出さない
    @hosts = Host.visible_in_list.includes(:events).order(name: :asc)
    @sellers = Seller.visible_in_list.includes(:events).order(name: :asc)
  end

  def show
    if params[:id].blank?
          redirect_to facilities_path, alert: 'IDが指定されていません。'
          return
        end

        @facility = Facility.find_by(id: params[:id])
    if @facility.nil?
      redirect_to facilities_path, alert: '施設が見つかりません。'
      return
    end
    
    @breadcrumbs = [{name: "ホーム", path: root_path}, {name: "出店一覧", path: facilities_path}, {name: @facility.name, path: facility_path(@facility)}]
  end
end
