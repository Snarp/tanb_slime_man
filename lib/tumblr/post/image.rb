module Tumblr
  class Post
    class Image
      def initialize(hash)
        @hash=hash
      end

      def url(width=nil)
        if width.nil?
          return orig_size
        else
          if val=@hash[:alt_sizes].detect {|img| img[:width]==width}
            return val[:url]
          else
            return orig_size
          end
        end
      end
      alias_method :src, :url

      def orig_size
        @hash[:original_size][:url]
      end

      def smallest
        @hash[:alt_sizes].last[:url]
      end

      def caption
        @hash[:caption]
      end
      def caption?
        !!@hash[:caption] && !@hash[:caption].strip.empty?
      end

      def alt
        @hash[:alt]
      end
      def alt?
        !!@hash[:alt] && !@hash[:alt].strip.empty?
      end

      def exif
        @hash[:exif]
      end


      # -- ACCESSORS


      def urls
        @hash[:alt_sizes].map { |img| img['url'] }.uniq
      end
      def widths
        @hash[:alt_sizes].map { |img| img['width'].to_i }.uniq
      end
      def heights
        @hash[:alt_sizes].map { |img| img['height'].to_i }.uniq
      end


      def to_h
        @hash
      end
      def [](key)
        @hash[key]
      end

    end # class Image
  end # class TumblrPost
end # module Tumblr