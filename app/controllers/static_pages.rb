# module StaticPages

  get "/" do
    redirect("/dashboard") if tumblr_authorized?
    @title = page_title()
    erb :index
  end

# end
# include StaticPages