
if respond_to?(:require_relative, true)
  require_relative 'common'
else
  require File.dirname(__FILE__) + '/common'
end

describe RestGraph do

  it 'would return nil if parse error, but not when call data directly' do
    rg = RestGraph.new
    rg.parse_cookies!({}).should == nil
    rg.data              .should == {}
  end

  it 'would extract correct access_token or fail checking sig' do
    access_token = '1|2-5|f.'
    app_id       = '1829'
    secret       = app_id.reverse
    sig          = '398262caea8442bd8801e8fba7c55c8a'
    fbs          = "\"access_token=#{CGI.escape(access_token)}&expires=0&" \
                   "secret=abc&session_key=def-456&sig=#{sig}&uid=3\""

    check = lambda{ |token|
      http_cookie =
        "__utma=123; __utmz=456.utmcsr=(d)|utmccn=(d)|utmcmd=(n); " \
        "fbs_#{app_id}=#{fbs}"

      rg  = RestGraph.new(:app_id => app_id, :secret => secret)
      rg.parse_rack_env!('HTTP_COOKIE' => http_cookie).
                      should.kind_of?(token ? Hash : NilClass)
      rg.access_token.should ==  token

      rg.parse_rack_env!('HTTP_COOKIE' => nil).should == nil
      rg.data.should == {}

      rg.parse_cookies!({"fbs_#{app_id}" => fbs}).
                      should.kind_of?(token ? Hash : NilClass)
      rg.access_token.should ==  token

      rg.parse_fbs!(fbs).
                      should.kind_of?(token ? Hash : NilClass)
      rg.access_token.should ==  token
    }
    check.call(access_token)
    fbs.chop!
    fbs += '&inject=evil"'
    check.call(nil)
  end

  it 'would not pass if there is no secret, prevent from forgery' do
    rg = RestGraph.new
    rg.parse_fbs!('"feed=me&sig=bddd192cf27f22c05f61c8bea24fa4b7"').
      should == nil
  end

end
