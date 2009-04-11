require File.dirname(__FILE__) + '/test_helper.rb'

class ViddlerTest < Test::Unit::TestCase

  TEST_VIDEO_FILE_PATH  = '/home/petyo/Test/sample.vob'
  
  def setup
    config = YAML.load_file File.join(File.dirname(__FILE__), 'viddler.yml') rescue "you need test/viddler.yml, check viddler.yml.example for credentals."
    @viddler = Viddler::Base.new(config['api_key'], config['login'], config['password'])
  end

  def test_should_authenticate
    @viddler.authenticate
    assert @viddler.authenticated?
  end
  
  def test_should_get_record_token
    token = @viddler.get_record_token
    assert_kind_of String, token
  end
  
  def test_should_upload_video
    file = File.open(TEST_VIDEO_FILE_PATH)
    video = @viddler.upload_video(:file => file, :title => 'Testing', :description => 'Bla', :tags => 'one, two, three', :make_public => '1')
  end
  
  def test_should_find_profile
    user = @viddler.find_profile('ilya')
    assert_kind_of Viddler::User, user
  end
  
  def test_should_update_profile
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
    assert @viddler.update_account(:show_account => '0')
  end
  
=begin
  def test_should_get_video_status
    assert @viddler.get_video_status('6b0b9af1')
  end
=end
  
  def test_should_find_video_by_id
    video = @viddler.find_video_by_id('6b0b9af1')
    assert_kind_of Viddler::Video, video
  end
  
  def test_should_get_dimensions
    video = @viddler.find_video_by_id('6b0b9af1')
    assert_equal 640, video.width
    assert_equal 360, video.height
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

end
