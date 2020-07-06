require 'active_support/core_ext/hash'
require 'sinatra/json'

# module TumblrPages

  get '/info' do
    redirect("/") unless tumblr_authorized?
  end

  get '/dashboard' do
    redirect("/") unless tumblr_authorized?
    args = normalize_request(params)
    json = args.delete :json
    resp = get_dashboard(args)
    if   !resp.is_a?(Hash)
      halt_error(resp.status, resp.message)
    elsif json
      json resp
    else
      @page = Tumblr::DashboardPage.new(posts: resp[:posts], request: args)
      @title = "Dashboard"

      if @page.newer_page
        @newer_path = "/dashboard?#{@page.newer_page.to_query}"
      end
      if @page.older_page
        @older_path = "/dashboard?#{@page.older_page.to_query}"
      end
      erb :tumblr_dashboard
    end
  end

  # TODO: Test with nonexistent blog, empty, etc.
  get '/blog/:blog' do
    args = normalize_request(params)
    json      = args.delete :json
    blog_id   = args.delete :blog
    prev_page = args.delete :prev
    next_page = args.delete :next

    resp = get_posts(blog_id, args)
    if   !resp.is_a?(Hash)
      halt_error(resp.status, resp.message)
    elsif json
      json resp
    else
      @page=Tumblr::BlogPage.new(request: args, newer_page: prev_page, **resp)
      @title  = "#{@page.name}"
      @title += " - ##{@page.tag}" if @page.tag

      if @page.newer_page
        @newer_path = "/blog/#{@page.uuid}?#{@page.newer_page.to_query}"
      end
      if @page.older_page
        @older_path = "/blog/#{@page.uuid}?#{@page.older_page.to_query}"
      end
      erb :tumblr_blog
    end
  end

  get '/tag/:tag' do
    args      = normalize_request(params)
    json      = args.delete :json
    tag       = args.delete :tag
    prev_page = args.delete :prev
    resp      = get_tag(tag, args)
    if   !resp.is_a?(Array)
      halt_error(resp.status, resp.message)
    elsif json
      json resp
    else
      @page = Tumblr::TagPage.new(posts: resp, request: args, newer_page: prev_page)
      @title = "##{tag}"

      if @page.newer_page
        @newer_path = "/tag/#{tag}?#{@page.newer_page.to_query}"
      end
      if @page.older_page
        @older_path = "/tag/#{tag}?#{@page.older_page.to_query}"
      end
      erb :tumblr_tag
    end
  end





  # AUTHENTICATION
  # ------

  get '/login' do
    redirect to '/auth/tumblr'
  end
  get '/logout' do
    session[:tumblr_oauth_token]=nil
    session[:tumblr_oauth_secret]=nil
    session[:tumblr_user_id]=nil
    redirect to '/'
  end

  get '/auth/tumblr/callback' do
    halt_error(401) unless env['omniauth.auth']

    auth                                = request.env['omniauth.auth']
    session[:tumblr_user_id]            = auth['uid']
    session[:tumblr_oauth_token]        = auth['credentials']['token']
    session[:tumblr_oauth_token_secret] = auth['credentials']['secret']

    redirect to '/dashboard'
  end
  get '/auth/failure' do
    halt_error(401, message: params[:message])
  end

# end
# include TumblrPages