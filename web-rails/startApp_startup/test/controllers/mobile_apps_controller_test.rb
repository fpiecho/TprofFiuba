require 'test_helper'

class MobileAppsControllerTest < ActionController::TestCase
  setup do
    @mobile_app = mobile_apps(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mobile_apps)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mobile_app" do
    assert_difference('MobileApp.count') do
      post :create, mobile_app: { description: @mobile_app.description, title: @mobile_app.title }
    end

    assert_redirected_to mobile_app_path(assigns(:mobile_app))
  end

  test "should show mobile_app" do
    get :show, id: @mobile_app
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @mobile_app
    assert_response :success
  end

  test "should update mobile_app" do
    patch :update, id: @mobile_app, mobile_app: { description: @mobile_app.description, title: @mobile_app.title }
    assert_redirected_to mobile_app_path(assigns(:mobile_app))
  end

  test "should destroy mobile_app" do
    assert_difference('MobileApp.count', -1) do
      delete :destroy, id: @mobile_app
    end

    assert_redirected_to mobile_apps_path
  end
end
