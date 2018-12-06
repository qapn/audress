require 'test_helper'

class AddressesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @address = addresses(:one)
  end

  test "should get index" do
    get addresses_url, as: :json
    assert_response :success
  end

  test "should create address" do
    assert_difference('Address.count') do
      post addresses_url, params: { address: { address_detail_pid: @address.address_detail_pid, alias_principal: @address.alias_principal, autocomplete: @address.autocomplete, building_name: @address.building_name, confidence: @address.confidence, date_created: @address.date_created, flat_number: @address.flat_number, flat_number_prefix: @address.flat_number_prefix, flat_number_suffix: @address.flat_number_suffix, flat_type: @address.flat_type, geocode_type: @address.geocode_type, latitude: @address.latitude, legal_parcel_id: @address.legal_parcel_id, level_number: @address.level_number, level_number_prefix: @address.level_number_prefix, level_number_suffix: @address.level_number_suffix, level_type: @address.level_type, locality_name: @address.locality_name, locality_pid: @address.locality_pid, longitude: @address.longitude, lot_number: @address.lot_number, lot_number_prefix: @address.lot_number_prefix, lot_number_suffix: @address.lot_number_suffix, number_first: @address.number_first, number_first_prefix: @address.number_first_prefix, number_first_suffix: @address.number_first_suffix, number_last: @address.number_last, number_last_prefix: @address.number_last_prefix, number_last_suffix: @address.number_last_suffix, postcode: @address.postcode, primary_secondary: @address.primary_secondary, state_abbreviation: @address.state_abbreviation, street_class_code: @address.street_class_code, street_class_type: @address.street_class_type, street_locality_pid: @address.street_locality_pid, street_name: @address.street_name, street_suffix_code: @address.street_suffix_code, street_suffix_type: @address.street_suffix_type, street_type_code: @address.street_type_code } }, as: :json
    end

    assert_response 201
  end

  test "should show address" do
    get address_url(@address), as: :json
    assert_response :success
  end

  test "should update address" do
    patch address_url(@address), params: { address: { address_detail_pid: @address.address_detail_pid, alias_principal: @address.alias_principal, autocomplete: @address.autocomplete, building_name: @address.building_name, confidence: @address.confidence, date_created: @address.date_created, flat_number: @address.flat_number, flat_number_prefix: @address.flat_number_prefix, flat_number_suffix: @address.flat_number_suffix, flat_type: @address.flat_type, geocode_type: @address.geocode_type, latitude: @address.latitude, legal_parcel_id: @address.legal_parcel_id, level_number: @address.level_number, level_number_prefix: @address.level_number_prefix, level_number_suffix: @address.level_number_suffix, level_type: @address.level_type, locality_name: @address.locality_name, locality_pid: @address.locality_pid, longitude: @address.longitude, lot_number: @address.lot_number, lot_number_prefix: @address.lot_number_prefix, lot_number_suffix: @address.lot_number_suffix, number_first: @address.number_first, number_first_prefix: @address.number_first_prefix, number_first_suffix: @address.number_first_suffix, number_last: @address.number_last, number_last_prefix: @address.number_last_prefix, number_last_suffix: @address.number_last_suffix, postcode: @address.postcode, primary_secondary: @address.primary_secondary, state_abbreviation: @address.state_abbreviation, street_class_code: @address.street_class_code, street_class_type: @address.street_class_type, street_locality_pid: @address.street_locality_pid, street_name: @address.street_name, street_suffix_code: @address.street_suffix_code, street_suffix_type: @address.street_suffix_type, street_type_code: @address.street_type_code } }, as: :json
    assert_response 200
  end

  test "should destroy address" do
    assert_difference('Address.count', -1) do
      delete address_url(@address), as: :json
    end

    assert_response 204
  end
end
