require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/object/blank'

module TumblrHelpers

  def tumblr_client
    Tumblr::Client.new({
      consumer_key:       ENV['TUMBLR_CONSUMER_KEY'], 
      consumer_secret:    ENV['TUMBLR_CONSUMER_SECRET'], 
      oauth_token:        session[:tumblr_oauth_token], 
      oauth_token_secret: session[:tumblr_oauth_token_secret], 
    })
  end



  # GET METHODS
  # ------

  def get_dashboard(args={})
    return tumblr_client.dashboard(**normalize_request(args))
  end

  def get_posts(blog_id, args={})
    return tumblr_client.posts(blog_id, **normalize_request(args))
  end

  def get_tag(tag, args={})
    return tumblr_client.tagged(tag, **normalize_request(args))
  end




  # REQUEST HELPERS
  # ------

  def normalize_request(args)
    args = args.deep_symbolize_keys

    [:offset,:limit,:since_id,:before_id,:before,:after,:id,:size].each do |k|
      if args[k] && (int=args[k].to_i) > 0
        args[k] = int
      end
    end

    [:reblog_info,:notes_info,:npf].each do |k|
      next unless args[k]
      args[k] = (args[k].downcase=='true')
    end

    return args
  end



  # AUTHORIZATION / LOGIN / LOGOUT
  # ------

  def tumblr_authorized?
    !!(session[:tumblr_oauth_token] && session[:tumblr_oauth_token_secret])
  end

  def authenticate_tumblr_user
    halt_error(401) unless env['omniauth.auth']

    auth                                = request.env['omniauth.auth']
    session[:tumblr_user_id]            = auth['uid']
    session[:tumblr_oauth_token]        = auth['credentials']['token']
    session[:tumblr_oauth_token_secret] = auth['credentials']['secret']
  end

  def tumblr_log_out
    session[:tumblr_oauth_token]=nil
    session[:tumblr_oauth_secret]=nil
    session[:tumblr_user_id]=nil
  end

end
# include TumblrHelpers
