module Tumblr
  class Post
    class Imageset
      attr_reader :images, :layout

      def initialize(photos: [], photoset_layout: nil, **dropped)
        @images = photos.map { |p| Image.new(p) }
        if photoset_layout
          @layout = photoset_layout.chars.map {|c| c.to_i}
        else
          @layout = [1]
        end
      end

      def rows(images=@images, layout=@layout)
        i=0
        @layout.map do |row_size|
          start_at = i
          i       += row_size
          @images.slice(start_at..i-1)
        end
      end

      alias_method :photos, :images

      def to_a
        @images
      end

      def to_h
        { images: @images, layout: @layout }
      end

      def [](key)
        to_a[key]
      end

    end
  end # class Post
end # module Tumblr