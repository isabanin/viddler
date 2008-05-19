module Viddler
  
  # Generic Viddler exception class.
  class ViddlerError < StandardError #:nodoc:
  end
  
  # Raised when username and password has not been set.
  class AuthenticationRequiredError < ViddlerError #:nodoc:
    def message
      'Method that you re trying to execute requires username and password.'
    end
  end

  # Raised when calling not yet implemented API methods.
  class NotImplementedError < ViddlerError #:nodoc:
    def message
      'This method is not yet implemented.'
    end
  end
  
  # A class that can be instantiated for access to a Viddler API.
  # 
  # Examples:
  #
  #   @viddler = Viddler::Base.new(API_KEY, USERNAME, PASSWORD)
  #
  # Username and password are optional, some API methods doesn't require them:
  #
  #   @viddler = Viddler::Base.new(YOUR_API_KEY)
  #
  class Base
    # Creates new viddler instance.
    #
    # Example:
    #
    #   @viddler = Viddler::Base.new(api_key, username, password)
    #
    def initialize(api_key, username=nil, password=nil)
      @api_key, @username, @password = api_key, username, password
      @session_id = nil
    end
    
    # Implements <tt>viddler.users.auth[http://wiki.developers.viddler.com/index.php/Viddler.users.auth]</tt>.
    #
    # It's not necessary for you to call this method manually before each method that requires authentication. Viddler.rb will do that for you automatically. You can use this method for checking credentials and for trying if connection to Viddler works.
    #
    # Example:
    #
    #  @viddler.authenticate
    #
    # Returns a string with session id.
    #
    def authenticate
      raise AuthenticationRequiredError unless could_authenticate?
      request = Viddler::Request.new(:get, 'users.auth')
      request.run do |p|
        p.api_key     = @api_key
        p.user        = @username
        p.password    = @password
      end
      @session_id = request.response['auth']['sessionid']
    end
    
    def authenticated?
      @session_id ? true : false
    end
    
    # Implements <tt>viddler.videos.getRecordToken[http://wiki.developers.viddler.com/index.php/Viddler.videos.getRecordToken]</tt>.
    #
    # Example:
    #
    #  @viddler.get_record_token
    #
    # Returns a string with record token.
    #
    def get_record_token
      authenticate unless authenticated?
      
      request = Viddler::Request.new(:get, 'videos.getRecordToken')
      request.run do |p|
        p.api_key     = @api_key
        p.sessionid   = @session_id
      end
      request.response['record_token']
    end
    
    # Implements <tt>viddler.users.register[http://wiki.developers.viddler.com/index.php/Viddler.users.register]</tt>. <b>Restricted to Viddler qualified API keys only.</b>
    #
    # <tt>new_attributes</tt> hash should contain next required keys:
    # * <tt>user:</tt> The chosen Viddler user name;
    # * <tt>email:</tt> The email address of the user;
    # * <tt>fname:</tt> The user's first name;
    # * <tt>lname:</tt> The user's last name;
    # * <tt>password:</tt> The user's password with Viddler;
    # * <tt>question:</tt> The text of the user's secret question;
    # * <tt>answer:</tt> The text of the answer to the secret question;
    # * <tt>lang:</tt> The language of the user for the account (e.g. EN)
    # * <tt>termsaccepted:</tt> "1" indicates the user has accepted Viddler's terms and conditions.
    #
    # and could contain next optional keys:
    # * <tt>company:</tt> The user's company affiliation.
    #
    # Example:
    #
    #  @viddler.register_user(:user => 'login', :email => 'mail@example.com', ...)
    #
    # Returns new user's username string.
    #
    def register_user(new_attributes={})
      Viddler::ApiSpec.check_attributes('users.register', new_attributes)
      
      request = Viddler::Request.new(:get, 'users.register')
      request.run do |p|
        p.api_key     = @api_key
        for param, value in new_attributes
          p.send("#{param}=", value)
        end
      end
      request.response['user']['username']
    end

    # Implements <tt>viddler.videos.upload[http://wiki.developers.viddler.com/index.php/Viddler.videos.upload]</tt>. Requires authentication.
    #
    # <tt>new_attributes</tt> hash should contain next required keys:
    # * <tt>title:</tt> The video title;
    # * <tt>description:</tt> The video description;
    # * <tt>tags:</tt> The video tags;
    # * <tt>file:</tt> The video file;
    # * <tt>make_public:</tt> Use "1" for true and "0" for false to choose whether or not the video goes public when uploaded.
    #
    # Example:
    #
    #  @viddler.upload_video(:title => 'Great Title', :file => File.open('/movies/movie.mov'), ...)
    #
    # Returns Viddler::Video instance. 
    #
    def upload_video(new_attributes={})
      authenticate unless authenticated?
      Viddler::ApiSpec.check_attributes('videos.upload', new_attributes)
        
      request = Viddler::Request.new(:post, 'videos.upload')
      request.run do |p|
        p.api_key     = @api_key
        p.sessionid   = @session_id
        for param, value in new_attributes
          p.send("#{param}=", value)
        end
      end
      Viddler::Video.new(request.response['video'])
    end
  
    # Implements <tt>viddler.users.getProfile[http://wiki.developers.viddler.com/index.php/Viddler.users.getProfile]</tt>.
    #
    # Example:
    #
    #  @viddler.find_profile(viddler_username)
    #
    # Returns Viddler::User instance. 
    #
    def find_profile(viddler_name)
      request = Viddler::Request.new(:get, 'users.getProfile')
      request.run do |p|
        p.api_key     = @api_key
        p.user        = viddler_name
      end
      Viddler::User.new request.response['user']
    end
    
    # Implements <tt>viddler.users.setProfile[http://wiki.developers.viddler.com/index.php/Viddler.users.setProfile]</tt>. Requires authentication.
    #
    # <tt>new_attributes</tt> hash could contain next optional keys:
    # * <tt>first_name</tt>
    # * <tt>last_name</tt>
    # * <tt>about_me</tt>
    # * <tt>birthdate:</tt> Birthdate in yyyy-mm-dd format;
    # * <tt>gender:</tt> Either m or y.
    # * <tt>company</tt>
    # * <tt>city</tt>
    #
    # Example:
    #
    #  @viddler.update_profile(:first_name => 'Vasya', :last_name => 'Pupkin')
    #
    # Returns Viddler::User instance. 
    #
    def update_profile(new_attributes={})
      authenticate unless authenticated?
      Viddler::ApiSpec.check_attributes('users.setProfile', new_attributes)
      
      request = Viddler::Request.new(:post, 'users.setProfile')
      request.run do |p|
        p.api_key   = @api_key
        p.sessionid = @session_id
        for param, value in new_attributes
          p.send("#{param}=", value)
        end
      end
      Viddler::User.new request.response['user']
    end
  
    # Implements <tt>viddler.users.setOptions[http://wiki.developers.viddler.com/index.php/Viddler.users.setOptions]</tt>. Requires authentication. <b>Restricted to Viddler partners only.</b>
    #
    # <tt>new_attributes</tt> hash could contain next optional keys:
    # * <tt>show_account:</tt> "1", "0" - Show/hide your account in Viddler. If you set it to "0" both your account and your videos won't be visible on viddler.com site
    # * <tt>tagging_enabled:</tt> "1", "0" - Enable/disable tagging on all your videos
    # * <tt>commenting_enabled:</tt> "1", "0" - Enable/disable commenting on all your videos
    # * <tt>show_related_videos:</tt> "1", "0" - Show/hide related videos on all your videos
    # * <tt>embedding_enabled:</tt> "1", "0" - Enable/disable embedding of off all your videos
    # * <tt>clicking_through_enabled:</tt> "1", "0" - Enable/disable redirect to viddler site while clicking on embedded player
    # * <tt>email_this_enabled:</tt> "1", "0" - Enable/disable email this option on all your videos
    # * <tt>trackbacks_enabled:</tt> "1", "0" - Enable/disable trackbacks on all your videos
    # * <tt>favourites_enabled:</tt> "1", "0" - Enable/disable favourites on all your videos
    # * <tt>custom_logo_enabled:</tt> "1", "0" - Enable/disable custom logo on all your videos. Note that logo itself must be send to viddler manually.
    #
    # Example:
    #
    #  @viddler.update_account(:show_account => '0')
    #
    # Returns number of updated parameters.
    #
    def update_account(new_attributes={})
      authenticate unless authenticated?
      Viddler::ApiSpec.check_attributes('users.setOptions', new_attributes)
      
      request = Viddler::Request.new(:get, 'users.setOptions')
      request.run do |p|
        p.api_key   = @api_key
        p.sessionid = @session_id
        for param, value in new_attributes
          p.send("#{param}=", value)
        end
      end
      request.response['updated'].to_i
    end
  
    # Implements <tt>viddler.videos.getStatus[http://wiki.developers.viddler.com/index.php/Viddler.vidoes.getStatus]</tt>.
    #
    # Example:
    #
    #  @viddler.get_video_status(video_id)
    #
    # This methods returns OpenStruct instance with Viddler's status information on a given video. We don't control what Viddler returns and it's all basically technical internal information of Viddler. Use this on your own risk.
    #
    def get_video_status(video_id)
      request = Viddler::Request.new(:get, 'videos.getStatus')
      request.run do |p|
        p.api_key     = @api_key
        p.video_id    = video_id
      end
      OpenStruct.new request.response['video_status']      
    end
  
    # Implements <tt>viddler.videos.getDetails[http://wiki.developers.viddler.com/index.php/Viddler.videos.getDetails]</tt>. Authentication is optional.
    #
    # Example:
    #
    #  @viddler.find_video_by_id(video_id)
    #
    # Returns Viddler::Video instance.
    #
    def find_video_by_id(video_id)
      # Authentication is optional for this request
      authenticate if could_authenticate? and !authenticated?
    
      request = Viddler::Request.new(:get, 'videos.getDetails')
      request.run do |p|
        p.api_key     = @api_key
        p.video_id    = video_id
        p.sessionid   = @session_id if authenticated?
      end
      Viddler::Video.new(request.response['video'])
    end
    
    # Implements <tt>viddler.videos.getDetailsByUrl[http://wiki.developers.viddler.com/index.php/Viddler.videos.getDetailsByUrl]</tt>. Authentication is optional.
    #
    # Example:
    #
    #  @viddler.find_video_by_url('http://www.viddler.com/explore/username/videos/video_num/')
    #
    # Returns Viddler::Video instance.
    #
    def find_video_by_url(video_url)
      # Authentication is optional for this request
      authenticate if could_authenticate? and !authenticated?
    
      request = Viddler::Request.new(:get, 'videos.getDetailsByUrl')
      request.run do |p|
        p.sessionid   = @session_id if authenticated?
        p.api_key     = @api_key
        p.url         = video_url      
      end
      Viddler::Video.new(request.response['video'])
    end
  
    # Implements <tt>viddler.videos.setDetails[http://wiki.developers.viddler.com/index.php/Viddler.videos.setDetails]</tt>. Requires authentication.
    #
    # <tt>new_attributes</tt> hash could contain next optional keys:
    # * <tt>title:</tt> Video title - 500 characters max
    # * <tt>description:</tt> Video description
    # * <tt>tags:</tt> List of tags to be set on video. Setting tags will update current tags set (both timed and global video tags). To set timed tag use format tagname[timestamp_in_ms] as tagname. For example - using tag1,tag2,tag3[2500] will set 2 global and 1 timed tag at 2.5s
    # * <tt>view_perm:</tt> View permission. Can be set to public, shared_all, shared or private
    # * <tt>view_users:</tt> List of users which may view this video if view_perm is set to shared. Only your viddler friends are allowed here. If you provide multiple usernames - non valid viddler friends usernames will be ignored.
    # * <tt>view_use_secret:</tt> If view_perm is set to non public value, you may activate secreturl for your video. If you want to enable or regenerate secreturl pass "1" as parameter value. If you want to disable secreturl pass "0" as parameter value.
    # * <tt>embed_perm:</tt> Embedding permission. Supported permission levels are the same as for view_perm. This and all permissions below cannot be less restrictive than view_perm. You cannot set it to public if view_perm is for example shared.
    # * <tt>embed_users:</tt> Same as view_users. If view_perm is shared, this list cannot contain more users than view_users. Invalid usernames will be removed.
    # * <tt>commenting_perm:</tt> Commenting permission. Description is the same as for embed_perm
    # * <tt>commenting_users:</tt> Same as embed_users.
    # * <tt>tagging_perm:</tt> Tagging permission. Description is the same as for embed_perm
    # * <tt>tagging_users:</tt> Same as embed_users.
    # * <tt>download_perm:</tt> Download permission. Description is the same as for embed_perm
    # * <tt>download_users:</tt> Same as embed_users.
    #
    # Example:
    #
    #  @viddler.update_video(video_id, :title => 'Brand new title')
    #
    # Returns Viddler::Video instance.
    #
    def update_video(video_id, new_attributes={})
      authenticate unless authenticated?
      Viddler::ApiSpec.check_attributes('videos.setDetails', new_attributes)
      
      request = Viddler::Request.new(:get, 'videos.setDetails')
      request.run do |p|
        p.api_key   = @api_key
        p.sessionid = @session_id
        p.video_id  = video_id
        for param, value in new_attributes
          p.send("#{param}=", value)
        end
      end
      Viddler::Video.new(request.response['video'])
    end
  
    # Implements <tt>viddler.videos.getByUser[http://wiki.developers.viddler.com/index.php/Viddler.videos.getByUser]</tt>. Authentication is optional.
    #
    # Options hash could contain next values:
    # * <tt>page</tt>: The "page number" of results to retrieve (e.g. 1, 2, 3);
    # * <tt>per_page</tt>: The number of results to retrieve per page (maximum 100). If not specified, the default value equals 20.
    #
    # Example:
    #
    #  @viddler.find_all_videos_by_user(username, :page => 2)
    #
    # Returns array of Viddler::Video instances.
    #
    def find_all_videos_by_user(username, options={})
      authenticate if could_authenticate? and !authenticated?
    
      options.assert_valid_keys(:page, :per_page)
    
      request = Viddler::Request.new(:get, 'videos.getByUser')
      request.run do |p|
        p.api_key     = @api_key
        p.sessionid   = @session_id if authenticated?
        p.user        = username
        p.page        = options[:page] || 1
        p.per_page    = options[:per_page] || 20      
      end
      parse_videos_list(request.response['video_list'])    
    end
    
    # Implements <tt>viddler.videos.getByTag[http://wiki.developers.viddler.com/index.php/Viddler.videos.getByTag]</tt>.
    #
    # Options hash could contain next values:
    # * <tt>page</tt>: The "page number" of results to retrieve (e.g. 1, 2, 3);
    # * <tt>per_page</tt>: The number of results to retrieve per page (maximum 100). If not specified, the default value equals 20.
    #
    # Example:
    #
    #  @viddler.find_all_videos_by_tag('super tag', :per_page => 5)
    #
    # Returns array of Viddler::Video instances.
    #
    def find_all_videos_by_tag(tag_name, options={})
      options.assert_valid_keys(:page, :per_page)
    
      request = Viddler::Request.new(:get, 'videos.getByTag')
      request.run do |p|
        p.api_key     = @api_key
        p.tag         = tag_name
        p.page        = options[:page] || 1
        p.per_page    = options[:per_page] || 20
      end
      parse_videos_list(request.response['video_list'])
    end
    
    # Implements <tt>viddler.videos.getFeatured[http://wiki.developers.viddler.com/index.php/Viddler.videos.getFeatured]</tt>.
    #
    # Example:
    #
    #  @viddler.find_all_featured_videos
    #
    # Returns array of Viddler::Video instances.
    #
    def find_all_featured_videos    
      request = Viddler::Request.new(:get, 'videos.getFeatured')
      request.run do |p|
        p.api_key     = @api_key
      end
      parse_videos_list(request.response['video_list'])
    end
  
    private
    
    def could_authenticate?
      @username and @password
    end
  
    def parse_videos_list(video_list)
      video_list['video'].collect do |attr|
        next unless attr.is_a?(Hash)
        Viddler::Video.new(attr)
      end
    end
  end
end