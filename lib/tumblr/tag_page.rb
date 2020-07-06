module Tumblr
  class TagPage
    attr_accessor :posts, :request

    def initialize(posts: [], request: {}, **dropped)
      @posts   = posts.map { |post| Tumblr::Post.new(post) }
      @request = request
    end

    def older_page
      return nil if oldest_page?
      @request.select do |k,v|
        !pager_keys.include?(k)
      end.merge before: @posts.last[:timestamp]
    end
    alias_method :next_page, :older_page

    def newer_page
    end
    alias_method :prev_page, :newer_page

    def newest_page?
      !@request.keys.include?(:before)
    end

    def oldest_page?
      @posts.count < 20
    end

    def to_h
      {
        request: @request, 
        posts:   @posts, 
      }
    end

  end
end