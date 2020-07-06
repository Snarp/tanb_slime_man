# module AdminPages

  get '/env' do
    redirect("/") if !settings.development?
    @title = "ENV"
    @payload = ENV.to_h
    erb :dev_dump
  end

  get '/auth' do
    redirect("/") if !settings.development?
    @title = "AUTH"
    @payload = tumblr_client.to_h
    erb :dev_dump
  end

  get '/session' do
    redirect("/") if !settings.development?
    @title = "SESSION"
    @payload = session.to_h
    erb :dev_dump
  end

# end
# include AdminPages