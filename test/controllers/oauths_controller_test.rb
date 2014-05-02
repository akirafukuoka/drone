require 'test_helper'

class OauthsControllerTest < ActionController::TestCase
  setup do
    @oauth = oauths(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:oauths)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create oauth" do
    assert_difference('Oauth.count') do
      post :create, oauth: { image: @oauth.image, name: @oauth.name, provider: @oauth.provider, publish: @oauth.publish, token: @oauth.token, token_expires_at: @oauth.token_expires_at, token_secret: @oauth.token_secret, uid: @oauth.uid }
    end

    assert_redirected_to oauth_path(assigns(:oauth))
  end

  test "should show oauth" do
    get :show, id: @oauth
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @oauth
    assert_response :success
  end

  test "should update oauth" do
    patch :update, id: @oauth, oauth: { image: @oauth.image, name: @oauth.name, provider: @oauth.provider, publish: @oauth.publish, token: @oauth.token, token_expires_at: @oauth.token_expires_at, token_secret: @oauth.token_secret, uid: @oauth.uid }
    assert_redirected_to oauth_path(assigns(:oauth))
  end

  test "should destroy oauth" do
    assert_difference('Oauth.count', -1) do
      delete :destroy, id: @oauth
    end

    assert_redirected_to oauths_path
  end
end
