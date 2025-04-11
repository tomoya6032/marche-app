class FacilityController < ApplicationController

  before_action :set_facility
  
  def index
  

    @facilities = Facility.all # 全ての施設を取得
    
    # if params[:facility_id].present?  ###ここから↓↓↓
    #   @facility = Facility.find(params[:facility_id])
    #   @events = @facility.events
    # else
    #   @events = Event.all # ここまでは仮置きの状態のコード。ログイン機能が実装できたら変える　facility_idがない場合は全てのイベントを表示
    # end

    # @events = @facility.events # 特定の施設に関連するイベントを取得

    
    
  end

  def show
    @facility = Facility.find(params[:id])
  end


  def set_facility
    # @facility = Facility.find(params[:facility_id]) # facility_idから特定の施設を取得
  end



end
