module Tumblr
  class DashboardPage
    attr_accessor :posts, :request

    def initialize(posts: [], request: {}, **dropped)
      @posts   = posts.map { |post| Tumblr::Post.new(post) }
      @request = request
    end

    def older_page
      return nil if oldest_page?
      @request.select do |k,v|
        !pager_keys.include?(k)
      end.merge before_id: @posts.last[:id]
    end
    alias_method :next_page, :older_page

    def newer_page
      return nil if @posts.empty?
      @request.select do |k,v|
        !pager_keys.include?(k)
      end.merge since_id: @posts.first[:id]
    end
    alias_method :prev_page, :newer_page

    def newest_page?
      (@request.keys - pager_keys).count < @request.keys
    end
    alias_method :first_page?, :newest_page?

    def oldest_page?
      @posts.count < 20
    end
    alias_method :last_page?, :oldest_page?

    def to_h
      {
        request:    @request, 
        posts:      @posts, 
        newer_page: newer_page, 
        older_page: older_page, 
      }
    end

    private
      def pager_keys
        [:offset,:before,:before_id,:since_id,:after,:page]
      end

  end
end