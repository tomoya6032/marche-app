class FacilityController < ApplicationController
  before_action :set_facility, only: [:edit, :update, :destroy]

  # 施設の一覧表示
  def index
    @facilities = Facility.all
  end

  # 施設の詳細表示
  def show
    @facility = Facility.first # 単一の施設を取得
    if @facility.nil?
      redirect_to root_path, alert: '施設が見つかりません。'
    end
  end

  # 新規施設作成フォームの表示
  def new
    @facility = Facility.new
  end

  # 新規施設の作成
  def create
    @facility = Facility.new(facility_params)
    if @facility.save
      redirect_to facility_path, notice: '施設が作成されました。'
    else
      render :new
    end
  end

  # 施設編集フォームの表示
  def edit
  end

  # 施設情報の更新
  def update
    if @facility.update(facility_params)
      redirect_to facility_path, notice: '施設情報が更新されました。'
    else
      render :edit
    end
  end

  # 施設の削除
  def destroy
    @facility.destroy
    redirect_to root_path, notice: '施設が削除されました。'
  end

  private

  # 特定の施設を取得
  def set_facility
    @facility = Facility.first
  end

  # Strong Parameters
  def facility_params
    params.require(:facility).permit(:name, :description, :address, :phone_number, :website, :latitude, :longitude, :facility_type, :image, :video)
  end
end
