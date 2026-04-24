require 'spaceship'

token = Spaceship::ConnectAPI::Token.create(
  key_id: "3RYV62XWSP",
  issuer_id: "d3533159-bf11-4529-a45d-ce8022d0322f",
  filepath: File.expand_path("~/.appstoreconnect/private_keys/AuthKey_3RYV62XWSP.p8")
)
Spaceship::ConnectAPI.token = token

app = Spaceship::ConnectAPI::App.find("com.gomath.mathlab")
abort "앱 없음" if app.nil?

puts "\n" + "=" * 70
puts " [1/3] App Store 메타데이터 점검 (v1.0)"
puts "=" * 70

versions = app.get_app_store_versions(filter: { versionString: "1.0" })
v = versions.first
if v.nil?
  puts "v1.0 버전이 없습니다."
else
  puts "Version State: #{v.app_store_state}"
  puts "Release Type: #{v.release_type}"
  puts "Platform: #{v.platform}"
  puts ""

  # 로컬라이제이션 (설명, 키워드 등)
  locs = v.get_app_store_version_localizations
  puts "▼ Localizations (#{locs.size})"
  locs.each do |loc|
    puts "  [#{loc.locale}]"
    puts "    Description: #{loc.description.nil? || loc.description.empty? ? '❌ 비어있음' : "✅ (#{loc.description.length}자)"}"
    puts "    Keywords: #{loc.keywords.nil? || loc.keywords.empty? ? '❌ 비어있음' : "✅ #{loc.keywords}"}"
    puts "    Promo Text: #{loc.promotional_text.nil? || loc.promotional_text.empty? ? '❌ 비어있음' : "✅ (#{loc.promotional_text.length}자)"}"
    puts "    What's New: #{loc.whats_new.nil? || loc.whats_new.empty? ? '⚠️  비어있음 (v1.0은 선택)' : "✅"}"
    puts "    Marketing URL: #{loc.marketing_url || '❌'}"
    puts "    Support URL: #{loc.support_url || '❌'}"
    # privacy_policy_url은 AppInfoLocalization에 있음
  end
  puts ""

  # 스크린샷
  puts "▼ 스크린샷"
  locs.each do |loc|
    begin
      sets = loc.get_app_screenshot_sets
      puts "  [#{loc.locale}] #{sets.size}개 device 세트"
      sets.each do |s|
        screenshots = s.app_screenshots
        puts "    - #{s.screenshot_display_type}: #{screenshots.size}장"
      end
    rescue => e
      puts "  [#{loc.locale}] 조회 실패: #{e.message}"
    end
  end
  puts ""

  # 앱 리뷰 정보 (심사 정보 — 데모 계정 등)
  begin
    review_detail = v.fetch_app_store_review_detail
    if review_detail
      puts "▼ 심사 정보 (App Review Detail)"
      puts "  Contact First Name: #{review_detail.contact_first_name || '❌'}"
      puts "  Contact Last Name: #{review_detail.contact_last_name || '❌'}"
      puts "  Contact Phone: #{review_detail.contact_phone || '❌'}"
      puts "  Contact Email: #{review_detail.contact_email || '❌'}"
      puts "  Demo Username: #{review_detail.demo_account_name || '(해당없음)'}"
      puts "  Demo Password: #{review_detail.demo_account_password ? '✅ 설정됨' : '(해당없음)'}"
      puts "  Demo Required: #{review_detail.demo_account_required}"
      puts "  Review Notes: #{review_detail.notes.nil? || review_detail.notes.empty? ? '⚠️  비어있음' : '✅ 작성됨'}"
    end
  rescue => e
    puts "▼ 심사 정보: 조회 실패 (#{e.message})"
  end
  puts ""
end

# AppInfo — 연령등급, 개인정보처리방침 등
puts "▼ App Info (카테고리, 개인정보)"
begin
  app_infos = app.fetch_edit_app_info ? [app.fetch_edit_app_info] : app.get_app_infos
  app_info = app.fetch_edit_app_info || app_infos.first
  if app_info
    puts "  Primary Category: #{app_info.primary_category&.id || '❌'}"
    puts "  Secondary Category: #{app_info.secondary_category&.id || '(선택)'}"
    loc = app_info.get_app_info_localizations.first
    if loc
      puts "  [#{loc.locale}]"
      puts "    Name: #{loc.name || '❌'}"
      puts "    Subtitle: #{loc.subtitle || '⚠️'}"
      puts "    Privacy URL: #{loc.privacy_policy_url || '❌ 필수!'}"
    end
  end
rescue => e
  puts "  조회 실패: #{e.message}"
end

puts "\n" + "=" * 70
puts " [2/3] TestFlight 내부 테스터 그룹"
puts "=" * 70

begin
  beta_groups = app.get_beta_groups(includes: "betaTesters")
  internal = beta_groups.select { |g| g.is_internal_group }
  external = beta_groups.reject { |g| g.is_internal_group }

  puts "\n▼ 내부 그룹 (#{internal.size})"
  internal.each do |g|
    testers = g.beta_testers || []
    puts "  - #{g.name} (#{testers.size}명)"
    testers.each do |t|
      puts "      · #{t.first_name} #{t.last_name} (#{t.email}) [#{t.state}]"
    end
  end

  puts "\n▼ 외부 그룹 (#{external.size})"
  external.each do |g|
    testers = g.beta_testers || []
    puts "  - #{g.name} (#{testers.size}명, public_link: #{g.public_link || '없음'})"
  end
rescue => e
  puts "조회 실패: #{e.message}"
end

puts "\n" + "=" * 70
puts " [3/3] 요약"
puts "=" * 70
puts "위 결과 기반으로 '❌' 표시된 항목을 App Store Connect 웹에서 채워야 심사 제출 가능."
puts "참고: https://appstoreconnect.apple.com/apps/#{app.id}/appstore"
