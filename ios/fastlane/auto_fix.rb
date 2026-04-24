require 'spaceship'

token = Spaceship::ConnectAPI::Token.create(
  key_id: "3RYV62XWSP",
  issuer_id: "d3533159-bf11-4529-a45d-ce8022d0322f",
  filepath: File.expand_path("~/.appstoreconnect/private_keys/AuthKey_3RYV62XWSP.p8")
)
Spaceship::ConnectAPI.token = token

app = Spaceship::ConnectAPI::App.find("com.gomath.mathlab")
PRIVACY_URL = "https://admin-web-bice.vercel.app/privacy"
SUPPORT_URL = "https://admin-web-bice.vercel.app"
CONTACT_EMAIL = "yeojoonsoo02@gmail.com"

puts "▶ 1. Privacy Policy URL 설정 (AppInfo)"
begin
  app_info = app.fetch_edit_app_info
  if app_info.nil?
    puts "  편집 가능한 AppInfo 없음 — 강제 생성 시도"
    app_infos = app.get_app_infos
    app_info = app_infos.first
  end

  locs = app_info.get_app_info_localizations
  locs.each do |loc|
    puts "  [#{loc.locale}] Privacy URL 설정 중..."
    loc.update(attributes: {
      privacyPolicyUrl: PRIVACY_URL
    })
    puts "  ✅ [#{loc.locale}] Privacy URL = #{PRIVACY_URL}"
  end
rescue => e
  puts "  ❌ 실패: #{e.message}"
  puts e.backtrace.first(3).join("\n")
end

puts ""
puts "▶ 2. Support URL 설정 (Version Localization)"
versions = app.get_app_store_versions(filter: { versionString: "1.0" })
v = versions.first
if v
  v.get_app_store_version_localizations.each do |loc|
    begin
      loc.update(attributes: {
        supportUrl: SUPPORT_URL,
        marketingUrl: SUPPORT_URL
      })
      puts "  ✅ [#{loc.locale}] Support/Marketing URL 업데이트"
    rescue => e
      puts "  ❌ [#{loc.locale}] 실패: #{e.message}"
    end
  end

  puts ""
  puts "▶ 3. 심사 정보 (App Review Detail) 설정"
  begin
    review_detail = begin
      v.fetch_app_store_review_detail
    rescue => e
      puts "  (기존 review_detail 없음: #{e.message})"
      nil
    end
    attrs = {
      contactFirstName: "Joonsoo",
      contactLastName: "Yeo",
      contactEmail: CONTACT_EMAIL,
      notes: "MathLab is a gamified math learning app. Test account is not required — you can use 'Guest Login' on the auth screen to access all features immediately. If you prefer email login, please register a new account with any email.",
      demoAccountRequired: false
    }

    if review_detail
      review_detail.update(attributes: attrs)
      puts "  ✅ 심사 정보 업데이트 (이름/이메일/노트)"
    else
      puts "  심사 정보 레코드 없음 — 신규 생성"
      resp = Spaceship::ConnectAPI.post_app_store_review_detail(
        app_store_version_id: v.id,
        attributes: attrs
      )
      puts "  ✅ 심사 정보 신규 생성 (id=#{resp.to_models.first&.id})"
    end
    puts "  ⚠️  전화번호(contactPhone)는 사용자 입력 필요 — 웹 콘솔에서 수동 입력"
  rescue => e
    puts "  ❌ 실패: #{e.message}"
    puts e.backtrace.first(5).join("\n")
  end
end

puts ""
puts "=" * 60
puts "완료. 웹 콘솔에서 확인:"
puts "https://appstoreconnect.apple.com/apps/#{app.id}/appstore"
