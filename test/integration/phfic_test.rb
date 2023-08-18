require "test_helper"

class PhficTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  test "root url works" do
    get root_url
    assert_response :success
  end

  test "hapi.fhir.org server is running" do
    assert_nothing_raised do
        hapi_response = RestClient.get "https://hapi.fhir.org/baseR4/metadata"
        JSON.parse hapi_response.body
        capability_statement = FHIR.from_contents(hapi_response.body)
    end
  end

  test "welcome connects to server and queries for a condition and stage" do
    post welcome_url, params: { server_url: 'https://hapi.fhir.org/baseR4', condition: Condition::CODE_OPTIONS.first.last, stage: Condition::STAGE_OPTIONS.first.last }
    assert_response :redirect

    follow_redirect!
    assert_response :success
  end
end
