require File.dirname(__FILE__) + '/test_helper.rb'

class ViddlerTest < Test::Unit::TestCase
  class KeyRequired < Exception
    def message
      'In order to run this test, insert working Viddler API key inside API_KEY constant.'
    end
  end  
  
  class CredentialsRequired < Exception
    def message
      'In order to run this test, insert working Viddler username and password inside LOGIN and PASSWORD constants.'
    end
  end
  
  # In order to run the tests you need a working Viddler account and an API key.
  API_KEY               = nil
  LOGIN                 = nil
  PASSWORD              = nil
  TEST_VIDEO_FILE_PATH  = '/path/to/video'
  
  def setup
    raise KeyRequired unless API_KEY
    @viddler = Viddler::Base.new(API_KEY, LOGIN, PASSWORD)
  end

  def test_should_authenticate
    credentials_required
    @viddler.authenticate
    assert @viddler.authenticated?
  end
  
  def test_should_get_record_token
    credentials_required
    token = @viddler.get_record_token
    assert_kind_of String, token
  end
  
  def test_should_upload_video
    credentials_required
    file = File.open(TEST_VIDEO_FILE_PATH)
    video = @viddler.upload_video(:file => file, :title => 'Testing', :description => 'Bla', :tags => 'one, two, three')
  end
  
  def test_should_find_profile
    user = @viddler.find_profile('ilya')
    assert_kind_of Viddler::User, user
  end
  
  def test_should_update_profile
    credentials_required
    user = @viddler.update_profile(:first_name => 'Ilya', 
                                   :last_name => 'Sabanin', 
                                   :about_me => 'A guy', 
                                   :birthdate => '1987-05-22',
                                   :gender => 'm',
                                   :company => 'Wildbit',
                                   :city => 'Krasnoyarsk')
    assert_kind_of Viddler::User, user
  end
  
  def test_should_update_account
    credentials_required
    assert @viddler.update_account(:show_account => '0')
  end
  
  def test_should_get_video_status
    assert @viddler.get_video_status('f8605d95')
  end
  
  def test_should_find_video_by_id
    video = @viddler.find_video_by_id('6b0b9af1')
    assert_kind_of Viddler::Video, video
  end
  
  def test_should_find_video_by_url
    video = @viddler.find_video_by_url('http://www.viddler.com/explore/ijustine/videos/293/')
    assert_kind_of Viddler::Video, video
  end
  
  def test_should_find_all_videos_by_user
    videos = @viddler.find_all_videos_by_user('ijustine')
    assert_kind_of Viddler::Video, videos.first
  end
  
  def test_should_find_all_videos_by_tag
    videos = @viddler.find_all_videos_by_tag('hot')
    assert_kind_of Viddler::Video, videos.first
  end
  
  def test_should_find_all_features_videos
    videos = @viddler.find_all_featured_videos
    assert_kind_of Viddler::Video, videos.first
  end
  
  private
  
  def credentials_required
    raise CredentialsRequired unless LOGIN and PASSWORD
  end

end
