
require 'test_helper'
require 'webmock'

WebMock.disable_net_connect!

class ApplicationControllerTest < ActionController::TestCase
  include WebMock

  def setup
    stub_request(:get, 'https://graph.facebook.com/me').
      to_return(:body => '{"error":"not authorized"}')
  end

  def teardown
    reset_webmock
  end

  def test_index
    get(:index)
    assert_response :redirect
    assert_equal(
      normalize_url(
        'https://graph.facebook.com/oauth/authorize?client_id=123&' \
        'scope=offline_access%2Cpublish_stream%2Cread_friendlists&' \
        'redirect_uri=http%3A%2F%2Ftest.host%2F'),
      normalize_url(assigns(:rest_graph_authorize_url)))
  end

  def test_canvas
    get(:canvas)
    assert_response :success
    assert_equal(
      normalize_url(
        'https://graph.facebook.com/oauth/authorize?client_id=123&' \
        'scope=publish_stream&'                                     \
        'redirect_uri=http%3A%2F%2Fapps.facebook.com%2Fcan%2Fcanvas'),
      normalize_url((assigns(:rest_graph_authorize_url))))
  end

  def test_options
    get(:options)
    assert_response :redirect
    assert_equal(
      normalize_url(
        'https://graph.facebook.com/oauth/authorize?client_id=123&' \
        'scope=bogus&'                                              \
        'redirect_uri=http%3A%2F%2Ftest.host%2Foptions'),
      normalize_url((assigns(:rest_graph_authorize_url))))
  end

  def test_no_auto
    get(:no_auto)
    assert_response :success
    assert_equal 'XD', @response.body
  end

  def test_app_id
    get(:app_id)
    assert_response :success
    assert_equal 'zzz', @response.body
  end

  def test_url_for_standalone
    get(:url_for_standalone)
    assert_response :success
    assert_equal 'http://test.host/', @response.body
  end

  def test_url_for_canvas
    get(:url_for_canvas)
    assert_response :success
    assert_equal 'http://apps.facebook.com/can/',
      @response.body
  end

  def test_url_for_view_stand
    get(:url_for_view_stand)
    assert_response :success
    assert_equal '/', @response.body
  end

  def test_url_for_view_canvas
    get(:url_for_view_canvas)
    assert_response :success
    assert_equal 'http://apps.facebook.com/can/',
      @response.body
  end

  def test_link_to_stand
    get(:link_to_stand)
    assert_response :success
    assert_equal '<a href="/">test</a>', @response.body
  end

  def test_link_to_canvas
    get(:link_to_canvas)
    assert_response :success
    assert_equal '<a href="http://apps.facebook.com/can/">test</a>',
      @response.body
  end

  def test_redirect_stand
    get(:redirect_stand)
    assert_response :redirect
    assert_redirected_to '/'
  end

  def test_redirect_canvas
    get(:redirect_canvas)
    assert_response :redirect
    assert_redirected_to 'http://apps.facebook.com/can/'
  end
end
