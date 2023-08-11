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

end
