# module StaticPages

  get "/" do
    redirect("/dashboard") if tumblr_authorized?
    @title = 'Page Title'
    erb :index
  end

# end
# include StaticPages