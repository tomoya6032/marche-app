class FacilityController < ApplicationController
  before_action :set_facility, only: [:edit, :update, :destroy]

  def index
    @facilities = Facility.all
  end

  def show
    @facility = Facility.first
    if @facility.nil?
      redirect_to root_path, alert: '施設が見つかりません。'
    end
  end

  def new
    @facility = Facility.new
  end

  def create
    @facility = Facility.new(facility_params)
    if @facility.save
      redirect_to facility_path, notice: '施設が作成されました。'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @facility.update(facility_params)
      redirect_to facility_path, notice: '施設情報が更新されました。'
    else
      render :edit
    end
  end

  def destroy
    @facility.destroy
    redirect_to root_path, notice: '施設が削除されました。'
  end

  private

  def set_facility
    @facility = Facility.first
  end

  def facility_params
    params.require(:facility).permit(:name, :description, :address, :phone_number, :website, :latitude, :longitude, :facility_type, :image, :video)
  end
end
