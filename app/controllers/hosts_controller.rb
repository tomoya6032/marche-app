# app/controllers/hosts_controller.rb
class HostsController < ApplicationController
  # authenticate_host! の適用範囲を見直し
  # show はログインしていなくても見れるので除外
  before_action :authenticate_host!, only: [:edit, :update, :destroy, :new_event, :create_event]
  
  # set_host の実行順序と対象アクションを調整
  # イベント関連のアクションでは、先にホストを見つけてからイベントを見つける
  before_action :set_host, only: [:edit, :update, :destroy, :new_event, :create_event, :edit_event, :update_event, :destroy_event, :show_event]
  before_action :set_event_for_nested_actions, only: [:edit_event, :update_event, :destroy_event, :show_event]
  
  # ★★★ index アクションの修正 ★★★
  def index
    @breadcrumbs = [{name: "ホーム", path: root_path}, {name: "ホスト一覧", path: hosts_path}]
    # ホストの一覧ページ（誰でも見れる）
    @hosts = Host.all.order(name: :asc) # 全ホストを名前順で取得
    # ここでは、@host = current_host のような行は不要です。
    # ログイン中のホストのコメントやイベントは、このページでは表示しません。
  end

  # ★★★ show アクションの修正 ★★★
  def show
    
    # ここはホストの公開ホームページです。

     # スラッグとして検索を試み、見つからなければIDとして検索
    @host = Host.find_by(slug: params[:id_or_slug]) || Host.find_by(id: params[:id_or_slug])

    unless @host
      # ホストが見つからなかった場合の処理 (例: 404エラー)
      render file: "#{Rails.root}/public/404.html", status: :not_found, layout: false
      return
    end
    
    @breadcrumbs = [{name: "ホーム", path: root_path}, {name: "ホスト一覧", path: hosts_path}, {name: @host.name, path: public_host_profile_path(@host.slug.presence || @host.id)}]

    # --- ホスト本人（current_host）にのみ表示する情報 ---
    if host_signed_in? && @host == current_host
      @admin_comments = @host.comments.order(created_at: :desc) # 管理者からのコメント（本人用）
      @host_events_for_management = @host.events.order(created_at: :desc) # ホストの全イベント（管理用）
      # ここにslugも確認できるように表示ロジックを追加できる
      @current_slug_for_display = @host.slug.presence || "未設定 (ID: #{@host.id})"
    end
    # --- ここまでホスト本人用 ---

    # --- 公開プロフィール用の情報（誰でも見れる部分） ---
    # イベントは開催日時が近い順に最大30件
      @public_events = @host.events.order(start_time: :asc).limit(15).includes(images_attachments: :blob)
    @topics_text = @host.topics # トピックスのテキストを取得
    @news_text = @host.news # 新着ニュースのテキストを取得
    @description_text = @host.description # 私たちについて
    @goods_introduction_1_text = @host.goods_introduction_1
    @goods_introduction_2_text = @host.goods_introduction_2
    @goods_introduction_3_text = @host.goods_introduction_3
    @goods_introduction_4_text = @host.goods_introduction_4

    # @events は show アクションの冒頭で @public_events として定義したので削除
    # @host.events.order(created_at: :desc).limit(10) も削除または用途に合わせて再定義
  end

  def edit
    @host = Host.find_by(slug: params[:host_id]) || Host.find_by(id: params[:host_id])
    # authenticate_host! により、ログイン中のホスト自身のページしか編集できないようになっているはず
    unless @host == current_host
      redirect_to root_path, alert: "他のホストのプロフィールは編集できません。"
    end
  end

  def update
    unless @host == current_host
      redirect_to root_path, alert: "他のホストのプロフィールは更新できません。" and return
    end

    # トップ画像の削除
    if params[:remove_top_image] == '1'
      @host.top_image.purge
    end

    # 削除する画像の処理 (host_params の更新とは独立して実行)
    if params[:host][:keep_images].present?
      keep_image_ids = params[:host][:keep_images].map { |signed_id| ActiveStorage::Blob.find_signed(signed_id).id }
      @host.images.each do |image|
        image.purge unless keep_image_ids.include?(image.blob_id)
      end
    else
      # keep_images が送信されない場合は、既存の画像を全て削除する
      @host.images.purge
    end

    if @host.update(host_params.except(:images))
       # 新しい画像の添付処理
      if params[:host][:images].present?
        params[:host][:images].each do |image|
          @host.images.attach(image)
        end
      end
      # ★★★ リダイレクト先のヘルパー修正 ★★★
      # update 後は、更新された @host の情報を使って show_host_profile_path にリダイレクト
      redirect_to public_host_profile_path(@host.slug.presence || @host.id), notice: 'プロフィールを更新しました。' # 修正
    else
      render :edit
    end
  end

  def destroy
    unless @host == current_host
      redirect_to root_path, alert: "他のホストのアカウントは削除できません。" and return
    end
    @host.destroy
    redirect_to root_path, notice: 'アカウントを削除しました。'
  end

  # ★★★ イベント詳細表示アクション ★★★
  def show_event
    # まずホストを特定します (スラッグまたはIDで)
    @host = Host.find_by(slug: params[:host_id]) || Host.find(params[:host_id])

    # そのホストに紐づくイベントを特定します
    @event = @host.events.find(params[:id])

     # イベントの最初の画像を取得
    @og_image = if @event.images.attached?
      url_for(@event.images.first)
    else
      view_context.asset_url('marchelogo2.png')
    end

    # ホストまたはイベントが見つからなかった場合の処理
    unless @host && @event
      redirect_to root_path, alert: "イベントが見つかりませんでした。"
      return # リダイレクト後はここで処理を終了
    end

    # ★★★ ここを修正: events/show.html.haml を明示的にレンダリングする ★★★
    render 'events/show'
  end

  # ★★★ イベントの新規作成アクションの修正（リダイレクト先） ★★★
  # ★★★ イベントの新規作成アクションの修正 ★★★
  def new_event
    unless @host == current_host
      redirect_to root_path, alert: "他のホストのイベントは作成できません。" and return
    end
    @event = @host.events.build(start_time: Time.zone.now, end_time: Time.zone.now + 1.hour)
    
    
    # ★ここを追加！都道府県のリストを設定します★
    # 日本の都道府県リストを配列として定義
    @prefectures = [
      '北海道', '青森県', '岩手県', '宮城県', '秋田県', '山形県', '福島県',
      '茨城県', '栃木県', '群馬県', '埼玉県', '千葉県', '東京都', '神奈川県',
      '新潟県', '富山県', '石川県', '福井県', '山梨県', '長野県', '岐阜県',
      '静岡県', '愛知県', '三重県', '滋賀県', '京都府', '大阪府', '兵庫県',
      '奈良県', '和歌山県', '鳥取県', '島根県', '岡山県', '広島県', '山口県',
      '徳島県', '香川県', '愛媛県', '高知県', '福岡県', '佐賀県', '長崎県',
      '熊本県', '大分県', '宮崎県', '鹿児島県', '沖縄県'
    ]
    # 明示的に `new_event.html.haml` をレンダリング
    render 'hosts/new_event'
  end

  def create_event
    unless @host == current_host
      redirect_to root_path, alert: "他のホストのイベントは作成できません。" and return
    end
    @event = @host.events.build(event_params)
    if @event.save
      # イベント作成後、ホストのホームページ（show）にリダイレクト

      redirect_to public_host_profile_path(id_or_slug: @host.slug.presence || @host.id), notice: 'イベントが作成されました。'
    else
      # エラー時の再描画も明示的にビューパスを指定
      @prefectures = [ # 都道府県リストを再設定
      '北海道', '青森県', '岩手県', '宮城県', '秋田県', '山形県', '福島県',
      '茨城県', '栃木県', '群馬県', '埼玉県', '千葉県', '東京都', '神奈川県',
      '新潟県', '富山県', '石川県', '福井県', '山梨県', '長野県', '岐阜県',
      '静岡県', '愛知県', '三重県', '滋賀県', '京都府', '大阪府', '兵庫県',
      '奈良県', '和歌山県', '鳥取県', '島根県', '岡山県', '広島県', '山口県',
      '徳島県', '香川県', '愛媛県', '高知県', '福岡県', '佐賀県', '長崎県',
      '熊本県', '大分県', '宮崎県', '鹿児島県', '沖縄県'
    ]
      render 'hosts/events/new' # new_event.html.haml が hosts/events/new.html.haml の場合
    end
  end

  # ★★★ イベントの編集・更新・削除アクションの修正 ★★★
  # `set_host` で @host が既に設定されていることを前提とします。
  def edit_event
    @host = Host.find_by(slug: params[:host_id]) || Host.find(params[:host_id])
    @event = @host.events.find(params[:id])

    unless @host == current_host
  redirect_to root_path, alert: "他のホストのイベントは編集できません。"
    end
    # 都道府県のリストが必要な場合
    @prefectures = [
      '北海道', '青森県', '岩手県', '宮城県', '秋田県', '山形県', '福島県',
      '茨城県', '栃木県', '群馬県', '埼玉県', '千葉県', '東京都', '神奈川県',
      '新潟県', '富山県', '石川県', '福井県', '山梨県', '長野県', '岐阜県',
      '静岡県', '愛知県', '三重県', '滋賀県', '京都府', '大阪府', '兵庫県',
      '奈良県', '和歌山県', '鳥取県', '島根県', '岡山県', '広島県', '山口県',
      '徳島県', '香川県', '愛媛県', '高知県', '福岡県', '佐賀県', '長崎県',
      '熊本県', '大分県', '宮崎県', '鹿児島県', '沖縄県'
    ]

     # ★★★ この行を追加または修正してください ★★★ 
     render 'hosts/events/edit' # ビューファイルの相対パスを明示的に指定

  end

  # app/controllers/hosts_controller.rb

  def update_event
    unless @host == current_host && @event.host == current_host
      redirect_to root_path, alert: "他のホストのイベントは更新できません。"
      return
    end
  
    # combine_datetime_parts(@event)
  
    # ユーザーが保持したいと明示的に指定した画像のsigned_idの配列
    requested_keep_signed_ids = Array(params[:event][:keep_images]).compact
    
    # 新しくアップロードされたファイル（空文字列は除外）
    new_images = Array(params[:event][:images]).reject(&:blank?)

    # ★★★ 修正ポイント: 保持したい既存のActiveStorage::Blobオブジェクトの配列を構築 ★★★
    # @event.images.blobs は現在のイベントに紐づくすべてのBlobオブジェクト
    # `image.signed_id` を使って比較するために、まずBlobを取得し、そのBlobのsigned_idを使う
    blobs_to_keep = @event.images.blobs.select do |blob|
      # blob.signed_id は `eyJfcmFpbHMiOnsiZGF0YSI6NN,InB1ciI6ImJsb2JfaWQifX0=--...` のような文字列
      requested_keep_signed_ids.include?(blob.signed_id)
    end

    # ★★★ イベントの更新に渡す最終的な画像配列を構築 ★★★
    # これには、保持したい既存のBlobオブジェクトと、新しくアップロードされたファイルが含まれる
    event_images_param = blobs_to_keep + new_images
    
    # Strong Parametersから`images`を削除して、`update_event_params`をクリーンにする
    event_params_without_images = update_event_params.except(:images) 
    
    # `images`を削除したパラメーターと、構築した画像配列を使って更新
    # ここで `images: event_images_param` を直接渡します。
    if @event.update(event_params_without_images.merge(images: event_images_param))
      redirect_to host_event_path(id_or_slug: @host.slug.presence || @host.id, id: @event.id), notice: 'イベントが更新されました。'
    else
      @prefectures = [ # 都道府県リストを再設定
        '北海道', '青森県', '岩手県', '宮城県', '秋田県', '山形県', '福島県',
        '茨城県', '栃木県', '群馬県', '埼玉県', '千葉県', '東京都', '神奈川県',
        '新潟県', '富山県', '石川県', '福井県', '山梨県', '長野県', '岐阜県',
        '静岡県', '愛知県', '三重県', '滋賀県', '京都府', '大阪府', '兵庫県',
        '奈良県', '和歌山県', '鳥取県', '島根県', '岡山県', '広島県', '山口県',
        '徳島県', '香川県', '愛媛県', '高知県', '福岡県', '佐賀県', '長崎県',
        '熊本県', '大分県', '宮崎県', '鹿児島県', '沖縄県'
      ]
      render 'hosts/events/edit'
    end
  end

  def destroy_event
    unless @host == current_host && @event.host == current_host
      redirect_to root_path, alert: "他のホストのイベントは削除できません。" and return
    end
    @event.destroy
    # イベント削除後、ホストのホームページ（show）にリダイレクト
    redirect_to public_host_profile_path(id_or_slug: @host.slug.presence || @host.id), notice: 'イベントが削除されました。'
  end

  private

  def set_host
    # このメソッドは show_event, edit_profile など、
    # host_id パラメータを持つ他のアクションのために残す。
    # show アクションは上の before_action で除外されているため、このメソッドは show では呼ばれない。
  
    # host_id パラメータがURLに含まれている場合（スラッグベースのルーティング）
    # params[:host_id] は、edit_profile, events/new などのネストされたパスで使用される
    if params[:host_id].present?
      @host = Host.find_by(slug: params[:host_id]) || Host.find_by(id: params[:host_id])
    # params[:id] は、resources :hosts で生成されるIDベースのパス（例えば /hosts/1 の編集ページなど）
    # ただし今回は resources :hosts, except: [:show] なので、id パラメータを持つ show 以外の hosts リソースパスは
    # 実質的に存在しないか、他のルーティングで処理されているはず
    elsif params[:id].present? && action_name != 'show' # showアクション以外でIDベースでホストを見つける場合
       @host = Host.find_by(id: params[:id])
    end
  
    unless @host
      # ★★★ リダイレクト先を修正 ★★★
      # ログイン中のホストがいるならそのプロフィールへ、いなければトップへ
      if host_signed_in? && current_host.persisted?
        redirect_to public_host_profile_path(id_or_slug: current_host.slug.presence || current_host.id), alert: "指定されたホストは見つかりませんでした。" and return
      else
        redirect_to root_path, alert: "指定されたホストが見つかりませんでした。" and return
      end
    end
  end


  
  # ★★★ set_event_for_nested_actions メソッドの修正 ★★★
  def set_event_for_nested_actions
    # @host が set_host で既に設定されていることを前提とします。
    # イベントIDは `params[:id]` で渡されます (resources :events の慣習)
    @event = @host.events.find(params[:id]) 
    rescue ActiveRecord::RecordNotFound
    # イベントが見つからなかった場合のリダイレクト先
    # 修正: host_path を public_host_profile_path に変更
    redirect_to public_host_profile_path(id_or_slug: @host.slug.presence || @host.id), alert: "指定されたイベントは見つかりませんでした。"
  end

  # ★★★ ここを修正します: event_params メソッド (create_event 用) ★★★
  # このメソッドに日時結合のロジックを含めます
  def event_params
    # まず、日時コンポーネントを含まない基本的なパラメータを許可
    permitted_params = params.require(:event).permit(
      :title, :description, :venue, :address, :latitude, :longitude,
      :capacity, :is_online, :online_url, :is_free, :price, :organizer,
      :contact_info, :website, :status, :video, :category_id, :prefecture,
      images: [] # create_event で画像アップロードを許可
    )

    # 各日時コンポーネントを params から取得し、結合して permitted_params に追加
    [:start_time, :end_time].each do |time_field|
      year = params[:event]["#{time_field}_year"]&.to_i
      month = params[:event]["#{time_field}_month"]&.to_i
      day = params[:event]["#{time_field}_day"]&.to_i
      hour = params[:event]["#{time_field}_hour"]&.to_i
      minute = params[:event]["#{time_field}_minute"]&.to_i
    
      if year.present? && month.present? && day.present? && hour.present? && minute.present?
        begin
          time_object = Time.zone.local(year, month, day, hour, minute)
          permitted_params[time_field] = time_object
        rescue ArgumentError => e
          Rails.logger.warn "Invalid date/time for #{time_field}: #{e.message} - Params: #{params[:event].slice("#{time_field}_year", "#{time_field}_month", "#{time_field}_day", "#{time_field}_hour", "#{time_field}_minute")}"
          permitted_params[time_field] = nil
        end
      else
        permitted_params[time_field] = nil
      end
    end
    permitted_params # 結合された日時が含まれたパラメータハッシュを返す
  end

   # ★★★ update_event_params メソッド (update_event 用) ★★★
   # これは既に正しく修正されているようです
  def update_event_params
    # まず、日時コンポーネントを含まない基本的なパラメータを許可
    permitted_params = params.require(:event).permit(
      :title, :description, :venue, :address, :latitude, :longitude,
      :capacity, :is_online, :online_url, :is_free, :price, :organizer,
      :contact_info, :website, :status, :video, :category_id, :prefecture
      # images: [] と keep_images: [] はここで permit しない。
      # update_event アクション内で手動で処理するため。
    )

    # 各日時コンポーネントを params から取得し、結合して permitted_params に追加
    [:start_time, :end_time].each do |time_field|
      year = params[:event]["#{time_field}_year"]&.to_i
      month = params[:event]["#{time_field}_month"]&.to_i
      day = params[:event]["#{time_field}_day"]&.to_i
      hour = params[:event]["#{time_field}_hour"]&.to_i
      minute = params[:event]["#{time_field}_minute"]&.to_i
    
      if year.present? && month.present? && day.present? && hour.present? && minute.present?
        begin
          time_object = Time.zone.local(year, month, day, hour, minute)
          permitted_params[time_field] = time_object
        rescue ArgumentError => e
          Rails.logger.warn "Invalid date/time for #{time_field}: #{e.message} - Params: #{params[:event].slice("#{time_field}_year", "#{time_field}_month", "#{time_field}_day", "#{time_field}_hour", "#{time_field}_minute")}"
          permitted_params[time_field] = nil
        end
      else
        permitted_params[time_field] = nil
      end
    end
    permitted_params # 結合された日時が含まれたパラメータハッシュを返す
  end

  def host_params
    params.require(:host).permit(
      :name, :email, :description, :address, :phone_number, :website, :slug, :top_image, :news, :topics, :business_hours_days, :business_hours_start, :business_hours_end,
      :goods_introduction_1, :goods_image_1,
      :goods_introduction_2, :goods_image_2,
      :goods_introduction_3, :goods_image_3,
      :goods_introduction_4, :goods_image_4,
      :contact_link,
      images: [],
      remove_top_image: [] # top_imageの削除フラグも許可
    )
  end



end