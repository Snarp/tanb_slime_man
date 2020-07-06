module Tumblr
  class Post
    module AnalysisMethods

      # EXTRACTING IMAGE URLS
      # ------

      # Returns all image URLs, including photoset images.
      def find_image_urls(**args)
        ::Tumblr::PostImageFinder.search_post_fields(@hash, **args)
      end


      # ORIGINALITY
      # ------

      def reblog?
        @hash[:reblogged_root_id] || @hash[:reblogged_from_id]
      end

      def commented_reblog?
        reblog? && !@hash.dig(:reblog, :comment).blank?
      end

      def op?
        !reblog? || @hash[:reblogged_root_uuid]==uuid
      end

      def original_material?(incl_tags: true)
        op? || commented_reblog? || @hash[:asking_name]==blog_name || (incl_tags && tagged?)
      end

      # Previous reblogs visible in the post body.
      def previous_reblogs
        return Array.new unless @hash[:trail]
        @hash[:trail].map do |post|
          { name: post[:blog][:name],
            id:   post[:post][:id],   }
        end
      end
      def reblogger_names
        previous_reblogs.map { |r| r[:name] }.uniq
      end

      # All usernames visibly associated with this reblog, including OP,
      # current user, and question-asker if any. Includes reblogged_from only
      # if they commented.
      def blog_names
        names = [@hash[:blog_name]]
        if reblog?
          names.push(op[:blog_name])
          names.concat(previous_reblogs.map { |post| post[:name] })
        end
        names.push(@hash[:asking_name]) if @hash[:asking_name]
        return names.uniq.select { |n| n }
      end


      # REBLOG INFO
      # ------

      def reblogged_from
        return nil unless @hash[:reblogged_from_id]
        {
          post_id:   @hash[:reblogged_from_id], 
          post_url:  @hash[:reblogged_from_url], 
          blog_id:   @hash[:reblogged_from_uuid], 
          blog_name: @hash[:reblogged_from_name], 
        }
      end
      alias_method :via, :reblogged_from

      def reblogged_root
        return nil unless @hash[:reblogged_root_id]
        {
          post_id:   @hash[:reblogged_root_id], 
          post_url:  @hash[:reblogged_root_url], 
          blog_id:   @hash[:reblogged_root_uuid], 
          blog_name: @hash[:reblogged_root_name], 
        }
      end
      alias_method :op, :reblogged_root

      def reblog_info
        fr,rt = reblogged_from,reblogged_root
        if fr || rt
          return { via: fr, op: rt, }
        else
          return nil
        end
      end

    end # module AnalysisMethods
  end # class Post
end 