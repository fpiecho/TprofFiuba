require 'test_helper'

class MobileAppScreensControllerTest < ActionController::TestCase
  setup do
    @mobile_app_screen = mobile_app_screens(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mobile_app_screens)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mobile_app_screen" do
    assert_difference('MobileAppScreen.count') do
      post :create, mobile_app_screen: { mobile_app: @mobile_app_screen.mobile_app, name: @mobile_app_screen.name }
    end

    assert_redirected_to mobile_app_screen_path(assigns(:mobile_app_screen))
  end

  test "should show mobile_app_screen" do
    get :show, id: @mobile_app_screen
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @mobile_app_screen
    assert_response :success
  end

  test "should update mobile_app_screen" do
    patch :update, id: @mobile_app_screen, mobile_app_screen: { mobile_app: @mobile_app_screen.mobile_app, name: @mobile_app_screen.name }
    assert_redirected_to mobile_app_screen_path(assigns(:mobile_app_screen))
  end

  test "should destroy mobile_app_screen" do
    assert_difference('MobileAppScreen.count', -1) do
      delete :destroy, id: @mobile_app_screen
    end

    assert_redirected_to mobile_app_screens_path
  end
end
