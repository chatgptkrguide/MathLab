require 'spaceship'
require 'digest'
require 'base64'

token = Spaceship::ConnectAPI::Token.create(
  key_id: "3RYV62XWSP",
  issuer_id: "d3533159-bf11-4529-a45d-ce8022d0322f",
  filepath: File.expand_path("~/.appstoreconnect/private_keys/AuthKey_3RYV62XWSP.p8")
)
Spaceship::ConnectAPI.token = token

SCREENSHOT_DIR = File.expand_path("screenshots/ko", __dir__)

unless Dir.exist?(SCREENSHOT_DIR)
  puts "❌ 스크린샷 디렉토리 없음: #{SCREENSHOT_DIR}"
  exit 1
end

files = Dir.glob(File.join(SCREENSHOT_DIR, "*.png")).sort
if files.empty?
  puts "❌ 업로드할 PNG 파일 없음 in #{SCREENSHOT_DIR}"
  exit 1
end

puts "📸 발견된 스크린샷: #{files.size}개"
files.each { |f| puts "  - #{File.basename(f)} (#{(File.size(f)/1024.0).round}KB)" }

app = Spaceship::ConnectAPI::App.find("com.gomath.mathlab")
v = app.get_app_store_versions(filter: { versionString: "1.0" }).first
abort "v1.0 없음" unless v

# ko 로컬라이제이션
loc = v.get_app_store_version_localizations.find { |l| l.locale == "ko" }
abort "ko localization 없음" unless loc

# 6.9" (iPhone 17 Pro Max) 스크린샷 세트 찾기 또는 생성
# Apple display type: APP_IPHONE_67
sets = loc.get_app_screenshot_sets
target_set = sets.find { |s| s.screenshot_display_type == "APP_IPHONE_67" }

if target_set.nil?
  puts ""
  puts "▶ APP_IPHONE_67 스크린샷 세트 신규 생성"
  target_set = Spaceship::ConnectAPI.post_app_screenshot_set(
    app_store_version_localization_id: loc.id,
    attributes: { screenshotDisplayType: "APP_IPHONE_67" }
  ).to_models.first
  puts "  ✅ Created set id=#{target_set.id}"
end

files.each do |file|
  puts ""
  puts "▶ Uploading #{File.basename(file)}..."
  begin
    Spaceship::ConnectAPI::AppScreenshot.create(
      app_screenshot_set_id: target_set.id,
      path: file,
      wait_for_processing: true
    )
    puts "  ✅ Uploaded"
  rescue => e
    puts "  ❌ 실패: #{e.message}"
    puts e.backtrace.first(3).join("\n")
  end
end

puts ""
puts "완료. https://appstoreconnect.apple.com/apps/#{app.id}/appstore"
