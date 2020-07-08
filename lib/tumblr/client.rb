require 'faraday'
require 'faraday_middleware'

module Tumblr
  class Client
    attr_reader   :parse_json
    attr_accessor :api_host, :api_path, :http_client, :opts

    def initialize(consumer_key:, 
                   consumer_secret:    nil, 
                   oauth_token:        nil, 
                   oauth_token_secret: nil, 
                   parse_json:         true, 
                   http_client:        Faraday::default_adapter, 
                   api_host:           "api.tumblr.com", 
                   api_path:           nil, 
                   **opts)
      @credentials = { 
        consumer_key:    consumer_key, 
        consumer_secret: consumer_secret, 
        token:           oauth_token, 
        token_secret:    oauth_token_secret 
      }.select {|k,v| v}
      @parse_json = parse_json
      @api_host,@http_client,@opts = api_host,http_client,opts
      @conn = config_conn(parse_json: @parse_json, credentials: @credentials, api_host: @api_host, **@opts)
    end



    # GET METHODS - USER

    def user_info(**args)
      get_body("v2/user/info", **args)
    end

    def user_following(limit: nil, offset: nil, **args)
      get_body('v2/user/following', limit: limit, offset: offset, **args)
    end

    def user_likes(limit: nil, offset: nil, before: nil, after: nil, **args)
      get_body('v2/user/likes', limit: limit, offset: offset, before: before, after: after, **args)
    end

    # NOTE: As of 2020-05-09, :before_id is working!, but still undocumented.
    #       (:before and :after still are not.)
    def dashboard(limit: nil, offset: nil, before_id: nil, since_id: nil, 
                  reblog_info: true, notes_info: nil, type: nil, npf: nil, **args)
      get_body('v2/user/dashboard', limit: limit, offset: offset, before_id: before_id,  since_id: since_id, reblog_info: reblog_info, notes_info: notes_info, npf: npf, **args)
    end



    # GET METHODS - BLOGS

    def blog_exists?(blog)
      resp = get_response("v2/blog/#{full_blog_id(blog)}/info")
      if   !resp.success?
        return false
      elsif @parse_json
        return resp.body[:response]
      else
        return resp.body
      end
    end
    alias_method :exists?, :blog_exists?

    def blog_info(blog, **args)
      get_body("v2/blog/#{full_blog_id(blog)}/info")
    end

    # Working pagination opts (2020-05-09): :before_id, :before, :after
    def posts(blog, type: nil, reblog_info: true, **args)
      path  = "v2/blog/#{full_blog_id(blog)}/posts"
      path += "/#{type}" if type
      get_body(path, reblog_info: reblog_info, **args)
    end
    alias_method :blog, :posts

    def npf_post(blog, post_id:, post_format: 'npf', **args)
      get_body("v2/blog/#{full_blog_id(blog)}/posts/#{post_id}", post_id: post_id, post_format: post_format, **args)
    end

    def queued(blog, offset: nil, limit: nil, filter: nil, **args)
      get_body("v2/blog/#{full_blog_id(blog)}/posts/queue", offset: offset, limit: limit, filter: filter, **args)
    end

    def drafts(blog, before_id: nil, filter: nil, **args)
      get_body("v2/blog/#{full_blog_id(blog)}/posts/draft", before_id: before_id, filter: filter, **args)
    end

    def submissions(blog, offset: nil, filter: nil, **args)
      get_body("v2/blog/#{full_blog_id(blog)}/posts/submission", offset: offset, filter: filter, **args)
    end

    def blog_likes(blog, limit: nil, offset: nil, before: nil, after: nil, 
                   **args)
      get_body("v2/blog/#{full_blog_id(blog)}/likes", limit: limit, offset: offset, before: before, after: after, **args)
    end

    def blog_followers(blog, limit: nil, offset: nil, **args)
      get_body("v2/blog/#{full_blog_id(blog)}/followers", limit: limit, offset: offset, **args)
    end



    # GET METHODS - TAGS

    def tagged(ttag=nil, tag: nil, before: nil, limit: nil, filter: nil, **args)
      get_body('v2/tagged', tag: (tag || ttag), before: before, limit: limit, filter: filter, **args)
    end
    alias_method :tag, :tagged



    # GET METHODS - GENERICIZED

    def info(blog=nil, **args)
      if blog
        return blog_info(blog, **args)
      else
        return user_info(**args)
      end
    end

    def likes(blog=nil, **args)
      if blog
        return blog_likes(blog, **args)
      else
        return user_likes(**args)
      end
    end

    def followers(blog=nil, **args)
      blog ||= user_info[:user][:name]
      return blog_followers(blog, **args)
    end



    # REQUESTS - BASIC

    def get_body(path, raise_errors: true, **args)
      resp = get_response(path, **args.select {|k,v| v})
      if resp.success? && @parse_json
        return resp.body[:response]
      elsif resp.success?
        return resp.body
      elsif raise_errors
        raise Faraday::ClientError.new("Error #{resp.status}: #{{path: path, args: args}}")
      else
        warn "Error #{resp.status}: #{{path: path, args: args}}"
        return resp
      end
    end

    def get_response(path, **args)
      conn.get(path, args)
    end



    # CONNECTION CONFIG

    def conn
      @conn ||= config_conn
    end
    def conn=(new_conn)
      @conn = new_conn
    end

    def parse_json=(val)
      if @parse_json!=val
        @parse_json=val
        config_conn
      end
      return val
    end

    def config_conn(credentials: @credentials, 
                    client:      @http_client, 
                    parse_json:  @parse_json, 
                    api_host:    @api_host, 
                    # api_path:    nil, 
                    log:         false, 
                    # retry_opts:  nil, 
                    **options)
      options = @opts if options.empty?
      options = {
        :headers => {
          :accept     => 'application/json',
          :user_agent => 'tumblr_client/0.8.5'
        },
        :url => "https://#{api_host}/", 
      }.merge(options)

      data = { api_host: api_host, ignore_extra_keys: true }.merge(credentials)

      # retry_opts ||= { max: 5, interval: 0.05, interval_randomness: 0.5, backoff_factor: 2 }

      @conn = Faraday.new(options) do |conn|
        conn.request  :oauth, data
        conn.request  :multipart
        conn.request  :url_encoded
        conn.request  :retry, max: 5, interval: 0.05, 
                              interval_randomness: 0.5, backoff_factor: 2
        conn.response :json, content_type: /\bjson$/, parser_options: {:symbolize_names=>true}                         if parse_json
        conn.response :logger                            if log
        conn.adapter  client
      end
    end

    def to_h
      { credentials: @credentials, api_host: @api_host, http_client: @http_client, parse_json: @parse_json, opts: @opts }
    end


    private

      def method_path(method_name, blog=nil, ext=nil)
        if    blog && ext
          return "v2/blog/#{full_blog_id(blog_id)}/#{method_name}/#{ext}"
        elsif blog && ['draft','queue','submissions'].include?(method_name)
          return "v2/blog/#{full_blog_id(blog_id)}/posts/#{method_name}"
        elsif blog
          return "v2/blog/#{full_blog_id(blog_id)}/#{method_name}"
        elsif method_name=='tagged'
          return "v2/tagged"
        else
          return "v2/user/#{method_name}"
        end
      end

      def full_blog_id(blog_id)
        if blog_id.include?('.') || blog_id.include?(':')
          return blog_id
        else
          return blog_id+".tumblr.com"
        end
      end

      def method_paths
        { # GET PATHS
          avatar:           'v2/blog/{{BLOG_ID}}/avatar', 
          blog_info:        'v2/blog/{{BLOG_ID}}/info', 
          blog_likes:       'v2/blog/{{BLOG_ID}}/likes', 
          posts:            'v2/blog/{{BLOG_ID}}/posts', 
          npf_post:         'v2/blog/{{BLOG_ID}}/posts/{{POST_ID}}', 
          followers:        'v2/blog/{{BLOG_ID}}/followers', 
          blog_following:   'v2/blog/{{BLOG_ID}}/following', 
          drafts:           'v2/blog/{{BLOG_ID}}/posts/draft', 
          queue:            'v2/blog/{{BLOG_ID}}/posts/queue', 
          submissions:      'v2/blog/{{BLOG_ID}}/posts/submission', 
          tagged:           'v2/tagged', 
          dashboard:        'v2/user/dashboard', 
          user_following:   'v2/user/following', 
          info:             'v2/user/info', 
          likes:            'v2/user/likes', 

          # POST paths: 
          post:             'v2/blog/{{BLOG_ID}}/post', 
          reblog:           'v2/blog/{{BLOG_ID}}/post/reblog', 
          delete:           'v2/blog/{{BLOG_ID}}/post/delete', 
          edit:             'v2/blog/{{BLOG_ID}}/post/edit', 
          follow:           'v2/user/follow', 
          unfollow:         'v2/user/unfollow', 
          like:             'v2/user/like', 
          unlike:           'v2/user/unlike', 
        }
      end

  end # class TumblrClient
end # module Tumblr