require "rubygems"
require "bundler"
Bundler.require :default, (ENV['RACK_ENV'] || "development").to_sym

require_relative "ica"

helpers do
  def basic_auth_credentials
    @auth ||= Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials
  end
end

get "/" do
  %{<title>#{AtomICA::NAME}</title><body><a href="https://github.com/henrik/atomica#readme">README.</a></body>}
end

get "/feed" do
  pnr, pwd = params[:pnr], params[:pwd]

  unless pnr && pwd
    pnr, pwd = basic_auth_credentials
  end

  unless pnr && pwd
    response["WWW-Authenticate"] = %{Basic realm="#{AtomICA::NAME} pnr/PIN"}
    throw :halt, [401, "Please provide personnummer and PIN as HTTP auth username/password or as pnr and pwd params."]
  end

  content_type "application/atom+xml"
  cache_control :public, max_age: 300  # 5 mins.
  AtomICA.new(pnr, pwd).render
end
