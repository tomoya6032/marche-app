# Active Storage variant generation (非同期・事前生成)

このプロジェクトでは、ページ読み込み時の画像バリアント生成による遅延を軽減するために、以下を実装しました:

- `GenerateImageVariantsJob` (ActiveJob): 指定したレコードの添付ファイルに対してバリアントを生成します。
- `rake active_storage:generate_variants`: 既存レコード向けにバリアント生成ジョブを一括でエンキューします。
- `AsyncVariantGenerator` concern: モデルにインクルードすると、該当添付ファイルが存在する場合にコミット後にジョブをエンキューします。

Usage
-----

1. 開発環境で即時に動かす（ActiveJobのデフォルトアダプタがasyncの場合）:

```bash
# 既存レコードの分を一括でエンキュー
bin/rails active_storage:generate_variants

# ジョブワーカーが必要な場合（Sidekiqをまだ使っていない場合は Rails のデフォルト async で処理されます）
```  

2. 本番では Sidekiq + Redis の使用を推奨

- `Gemfile` に `gem 'sidekiq'` を追加
- `config/application.rb` または `config/environments/production.rb` にて `config.active_job.queue_adapter = :sidekiq`
- Sidekiq を起動してジョブを処理する

注意
-----

- 大量の画像を一度に処理するとワーカーに負荷が掛かります。段階的に実行してください。
- ネイティブの `libvips` を導入すると、バリアント生成が高速化します（`ruby-vips` とシステムパッケージ `libvips` をインストール）。

次の改善案
----------------

- 画像形式として WebP の生成も行う
- 重要なページで使うサイズのみを限定して生成
- アップロード時にサーバ側で最適化（圧縮・リサイズ）を実行
