module Tumblr
  class BlogPage
    attr_accessor :blog_info, :posts, :request, :newer_page

    def initialize(blog:       {}, 
                   posts:      [], 
                   request:    {}, 
                   newer_page: nil, 
                   **dropped)
      @blog_info  = blog
      @posts      = posts.map { |post| Tumblr::Post.new(post) }
      @request    = request
      @newer_page = newer_page
    end

    alias_method :prev_page, :newer_page

    def name
      @blog_info[:name]
    end

    def uuid
      @blog_info[:uuid]
    end

    def tag
      @request[:tag]
    end


    def older_page
      if    @older_page
        return @older_page
      elsif !last_page?
        @older_page = @request.select do |k,v|
          !pager_keys.include?(k)
        end.merge before: @posts.last[:timestamp]
      end
    end
    alias_method :next_page, :older_page

    def first_page?
      (@request.keys - pager_keys).count < @request.keys
    end
    alias_method :newest_page?, :first_page?

    def last_page?
      @posts.count < 20
    end
    alias_method :oldest_page?, :last_page?


    def to_h
      {
        request: @request, 
        blog:    @blog_info, 
        posts:   @posts, 
      }
    end

    private
      def pager_keys
        [:offset,:before,:before_id,:since_id,:after,:page]
      end

  end
end