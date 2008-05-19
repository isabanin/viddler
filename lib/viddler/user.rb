module Viddler
  # This class wraps Viddler's user's information.
  class User
  
    attr_accessor :username,
                  :first_name,
                  :last_name, 
                  :about_me,
                  :avatar,
                  :age, 
                  :video_upload_count,
                  :video_watch_count,
                  :homepage,
                  :gender,
                  :company,
                  :city,
                  :friend_count,
                  :favourite_video_count
  
    def initialize(attributes={}) #:nodoc:
      a = attributes
      @username               = a['username']
      @first_name             = a['first_name']
      @last_name              = a['last_name']
      @about_me               = a['about_me']
      @avatar                 = a['avatar']
      @age                    = a['age'].to_i    
      @homepage               = a['homepage']
      @gender                 = a['gender']
      @company                = a['company']
      @city                   = a['city']
      @video_upload_count     = a['video_upload_count'].to_i
      @video_watch_count      = a['video_watch_count'].to_i
      @friend_count           = a['friend_count'].to_i
      @favourite_video_count  = a['favourite_video_count'].to_i
    end
  
  end
end