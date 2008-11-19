module Viddler
  # This class wraps Viddler's video's information.
  class Video
  
    attr_accessor :id, 
                  :url, 
                  :title, 
                  :description, 
                  :tags, 
                  :thumbnail_url,
                  :author, 
                  :length_seconds, 
                  :view_count, 
                  :upload_time,
                  :comment_count, 
                  :permissions, 
                  :comments,
                  :width,
                  :height
  
    def initialize(attributes={}) #:nodoc:
      @id               = attributes['id']
      @title            = attributes['title']
      @description      = attributes['description']
      @tags             = attributes['tags']
      @url              = attributes['url']
      @thumbnail_url    = attributes['thumbnail_url']
      @author           = attributes['author']
      @length_seconds   = attributes['length_seconds'].to_i
      @view_count       = attributes['view_count'].to_i
      @comment_count    = attributes['comment_count'].to_i
      @upload_time      = attributes['upload_time'] ? Time.at(attributes['upload_time'].to_i/1000) : nil
      @permissions      = attributes['permissions'] ? attributes['permissions'] : nil
      @comments         = attributes['comment_list'].values.flatten.collect do |comment| 
                            Viddler::Comment.new(comment)
                          end if attributes['comment_list']
      @width            = attributes['width'].to_i
      @height           = attributes['height'].to_i
    end
    
    # Returns proper HTML code for embedding
    #
    # <tt>options</tt> hash could contain:
    # * <tt>player_type:</tt> The type of player to embed, either "simple" or "player" (default is "player");
    # * <tt>width:</tt> The width of the player (default is 437);
    # * <tt>height:</tt> The height of the player (default is 370);
    # * <tt>autoplay:</tt> Whether or not to autoplay the video, either "t" or "f" (default is "f");
    # * <tt>playAll:</tt> Set to "true" to enable play all player (requires player_type to be "player");
    #
    # Any additional options passed to the method will be added as flashvars
    #
    # Example:
    #
    #  @video.embed_code(:player_type => 'simple', :width => 300, :height => 300, autoplay => 't')
    #
    # Returns embed code for auto playing simple player with 300px width and height
    #
    def embed_code(options={})
      options.reverse_merge! \
                  :player_type => 'player',
                  :width => 437,
                  :height => 370,
                  :autoplay => 'f',
                  :use_secret_url => false

      # get non flashvars from options
      player_type     = options.delete(:player_type)
      width           = options.delete(:width)
      height          = options.delete(:height)
      use_secret_url  = options.delete(:use_secret_url)

      flashvars = options.collect{|key,value| "#{key}=#{value}"}.join('&')

      additional = use_secret_url ? "0/#{permissions['view']['secreturl']}/" : ''

      html = <<CODE
<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width="#{width}" height="#{height}" id="viddlerplayer-#{self.id}">
<param name="movie" value="http://www.viddler.com/#{player_type}/#{self.id}/#{additional}" />
<param name="allowScriptAccess" value="always" />
<param name="allowFullScreen" value="true" />
<param name="flashvars" value="#{flashvars}" />
<embed src="http://www.viddler.com/#{player_type}/#{self.id}/#{additional}" width="#{width}" height="#{height}" type="application/x-shockwave-flash" allowScriptAccess="always" flashvars="#{flashvars}" allowFullScreen="true" name="viddlerplayer-#{self.id}" >
</embed>
</object>
CODE
    end
  
  end
end
