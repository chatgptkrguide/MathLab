require 'spaceship'

token = Spaceship::ConnectAPI::Token.create(
  key_id: "3RYV62XWSP",
  issuer_id: "d3533159-bf11-4529-a45d-ce8022d0322f",
  filepath: File.expand_path("~/.appstoreconnect/private_keys/AuthKey_3RYV62XWSP.p8")
)
Spaceship::ConnectAPI.token = token

bundle_id = "com.gomath.mathlab"
app = Spaceship::ConnectAPI::App.find(bundle_id)

if app.nil?
  puts "앱을 찾을 수 없습니다 (bundle_id: #{bundle_id})"
  exit 1
end

puts "=" * 60
puts "App Name: #{app.name}"
puts "Bundle ID: #{app.bundle_id}"
puts "App ID: #{app.id}"
puts "=" * 60
puts ""
puts "[App Store 버전 상태]"
versions = app.get_app_store_versions
if versions.empty?
  puts "  (App Store 버전 없음)"
else
  versions.each do |v|
    puts "  - Version: #{v.version_string} | Platform: #{v.platform}"
    puts "    State: #{v.app_store_state}"
    puts "    Created: #{v.created_date}"
    puts ""
  end
end

puts "=" * 60
puts "[TestFlight 최근 빌드 5개]"
builds = Spaceship::ConnectAPI::Build.all(
  app_id: app.id,
  sort: "-uploadedDate",
  limit: 5,
  includes: "betaAppReviewSubmission,buildBetaDetail,preReleaseVersion"
)

if builds.empty?
  puts "  (빌드 없음)"
else
  builds.each do |b|
    puts "  - Build: #{b.version} (#{b.pre_release_version&.version})"
    puts "    Uploaded: #{b.uploaded_date}"
    puts "    Processing: #{b.processing_state}"
    puts "    Expired: #{b.expired}"
    detail = b.build_beta_detail
    if detail
      puts "    Internal Beta: #{detail.internal_build_state}"
      puts "    External Beta: #{detail.external_build_state}"
    end
    sub = b.beta_app_review_submission
    if sub
      puts "    Beta Review: #{sub.beta_review_state}"
      puts "    Submission attrs: #{sub.instance_variables.map { |iv| [iv, sub.instance_variable_get(iv)] }.to_h rescue 'n/a'}"
    end
    puts ""
  end
end

puts "=" * 60
puts "[Build #2 상세 — 외부 테스터 그룹 / 심사 제출 이력]"
build2 = builds.find { |b| b.version == "2" }
if build2
  # 외부 테스터 그룹
  begin
    beta_groups = build2.get_beta_groups(includes: "betaTesters")
    puts "  External Beta Groups:"
    if beta_groups.empty?
      puts "    (그룹 없음 — 외부 테스터가 추가 안 됐을 수 있음)"
    else
      beta_groups.each do |g|
        puts "    - #{g.name} (public: #{g.is_internal_group ? 'internal' : 'external'})"
      end
    end
  rescue => e
    puts "  (beta groups 조회 실패: #{e.message})"
  end

  # Beta review submission 상세
  sub = build2.beta_app_review_submission
  if sub
    puts ""
    puts "  Beta Review Submission:"
    puts "    ID: #{sub.id}"
    puts "    State: #{sub.beta_review_state}"
  end
end
