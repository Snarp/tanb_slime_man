require_relative 'post/analysis_methods'
require_relative 'post/image'
require_relative 'post/imageset'

module Tumblr
  class Post
    include AnalysisMethods

    def initialize(hash={})
      @hash=hash
    end


    # ACCESSORS - BASIC
    # ------

    def blog_name
      @hash[:blog_name]
    end
    def blog_id
      @hash[:blog][:uuid]
    end
    alias_method :blog_uuid, :blog_id
    def blog_info
      @hash[:blog]
    end
    def blog_url
      @hash[:blog][:url]
    end

    # FIXME: This won't work for private blogs; apparently need at least API
    #        key, possibly full OAuthed request.
    def avatar_url(size: nil)
      if size.nil?
        "https://api.tumblr.com/v2/blog/#{blog_id}/avatar"
      else
        "https://api.tumblr.com/v2/blog/#{blog_id}/avatar/#{size.to_i}"
      end
    end

    def id
      @hash[:id]
    end
    def type
      @hash[:type].to_sym
    end
    def url
      @hash[:post_url]
    end
    def date(strftime="%Y-%m-%d %H:%M:%S %z")
      Time.at(@hash[:timestamp]).strftime(strftime)
    end
    def timestamp
      Time.at(@hash[:timestamp])
    end

    def slug
      @hash[:slug]
    end
    def slug?
      @hash[:slug] && @hash[:slug].strip!=""
    end

    def title
      @hash[:title]
    end
    def title?
      @hash[:title] && @hash[:title].strip!=""
    end

    def tags
      @hash[:tags]
    end
    def tagged?
      @hash[:tags].any?
    end

    def is_pinned
      @hash[:is_pinned]
    end
    alias_method :pinned?, :is_pinned

    # def body
    #   if   (@hash[:caption] || @hash[:body]) && @hash[:type]!='chat'
    #     return @hash[:caption] || @hash[:body]
    #   elsif @hash[:type]=='answer'
    #     "<blockquote class=\"question\">Q: <a href=\"#{@hash[:asking_url]}\">#{@hash[:asking_name]}</a>: #{@hash[:question]}</blockquote>\n<div class=\"answer\">A: #{@hash[:answer]}</div>"
    #   elsif @hash[:type]=='quote'
    #     return "<blockquote class=\"quote-text\">#{@hash[:text]}</blockquote>\n<div class=\"quote-source\">- #{@hash[:source]}</div>"
    #   elsif @hash[:type]=='link'
    #     return "<p><a class=\"post-link\" href=\"#{@hash[:url]}\">#{@hash[:title]}</a></p>\n<p class=\"excerpt\">#{@hash[:excerpt]}</p>\n<p class=\"description\">#{@hash[:description]}</p>"
    #   elsif @hash[:type]=='chat'
    #     @hash[:dialogue].map do |line|
    #       "<p><span class=\"name\">#{line[:name]}:</span> <span class=\"phrase\">#{line[:phrase]}</span></p>"
    #     end.join("\n")
    #   end
    # end

    def body
      @hash[:body] || @hash[:caption]
    end
    def caption
      @hash[:caption]
    end

    def trail
      @hash[:trail]
    end



    # MEDIA
    # ------

    def imageset
      @imageset ||= (Imageset.new(**@hash) if @hash[:photos])
    end
    alias_method :photoset, :imageset

    def media_player(width=nil)
      val = @hash[:player] || @hash[:embed]
      if    val.nil? || val.is_a?(String)
        return val
      elsif val.is_a?(Array)
        if width && player=val.detect{|h| h[:width]==width }
          return player[:embed_code]
        else
          return val.last[:embed_code]
        end
      else
        return nil
      end
    end


    # POST TYPES
    # ------

    def caption
      @hash[:caption]
    end
    def dialogue
      return @hash[:dialogue]
    end
    alias_method :chat, :dialogue
    
    def quote
      return nil if @hash[:type]!='quote'
      { text: @hash[:text], source: @hash[:source] }
    end
    def answer
      return nil if @hash[:type]!='answer'
      { asking_name: @hash[:asking_name], asking_url: @hash[:asking_url], 
        question: @hash[:question], answer: @hash[:answer] }
    end
    alias_method :ask, :answer
    def link
      return nil if @hash[:type]!='link'
      { title: @hash[:title], url: @hash[:url], excerpt: @hash[:excerpt], 
        description: @hash[:description] }
    end



    # PRIVACY
    # ------

    def published?
      @hash[:state]=='published'
    end
    def state
      @hash[:state].to_sym
    end


    # NOTES / INTERACTIONS
    # ------

    def liked?
      @hash[:liked]
    end

    def note_count
      @hash[:note_count]
    end

    # Valid types: ['reply','answer','reblog','like','posted']
    def notes(type=nil)
      if @hash[:notes] && type
        type=type.to_s
        return @hash[:notes].select {|n| n[:type]==type}
      else
        return @hash[:notes]
      end
    end

    # REVIEW: Remove later.
    def reblog_url
      "https://www.tumblr.com/reblog/#{@hash[:id]}/#{@hash[:reblog_key]}"
    end



    # HELPERS
    # ------

    def field_blank?(key)
      !@hash[key] || @hash[key].strip==''
    end

    def to_h
      @hash.to_h
    end

    def [](key)
      @hash[key]
    end

    def to_yaml
      @hash.to_yaml
    end

  end
end