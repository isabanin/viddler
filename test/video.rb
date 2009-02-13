require File.dirname(__FILE__) + '/test_helper.rb'

class ViddlerVideoTest < Test::Unit::TestCase
  
  ATTRIBUTES = [:id, 
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
              :height]
  
  def setup
    @attributes = { "permalink"           => "http://www.viddler.com/explore/mockaquinho/videos/2/", 
                    "title"               => "01_Vitinho",
                    "author"              => "mockaquinho",
                    "upload_time"         => "1227747942000",
                    "comment_count"       => 0, 
                    "url"                 => "http://www.viddler.com/explore/mockaquinho/videos/2/", 
                    "id"                  => "6a2babb2",
                    "length_seconds"      => 865, 
                    "description"         => "Vitinho pop star. Desde 07/12/2007.", 
                    "height"              => 480,
                    "made_public_time"    => "1227750542000",
                    "width"               => 640,
                    "view_count"          => 3,
                    "thumbnail_url"       => "http://cdn-thumbs.viddler.com/thumbnail_2_6a2babb2.jpg",
                    "tags"                => {"global" => "pop"}
                 }
    @video = Viddler::Video.new(@attributes)
  end
  
  
  def test_accessors_and_initialize
    expected_attributes = @attributes.merge("upload_time" => Time.at(1227747942000.to_i/1000), "tags" => ["pop"])
    ATTRIBUTES.each do |field|
      assert_equal expected_attributes[field.to_s], @video.send(field), "The expected value for #{field} is #{expected_attributes[field.to_s]} but got: #{@video.send(field)}"
    end
  end
  
  def test_embed_code_without_options
    expected_embed_code = File.read(File.dirname(__FILE__) + '/fixtures/embed_code.txt')
    assert_equal expected_embed_code, @video.embed_code 
  end
  
  def test_equals_when_should_be_equals
    second_video = Viddler::Video.new("id" => "6a2babb2")
    assert_equal second_video, @video
  end
  
  def test_equals_when_should_not_be_equals
    second_video = Viddler::Video.new("id" => "6a2babb3")
    assert_not_equal second_video, @video
  end

  def test_eql_when_should_be_equals
    second_video = Viddler::Video.new("id" => "6a2babb2")
    assert  @video.eql?(second_video)
  end

  def test_eql_when_should_not_be_equals
    second_video = Viddler::Video.new("id" => "6a2babb3")
    assert  !@video.eql?(second_video)
  end
  
  def test_hash
    assert_equal 6, @video.hash
  end
  
  def test_comparison
    second_video = Viddler::Video.new("title" => "02_Vitinho", "id" => "6a2babb2")
    assert_equal [second_video, @video], [@video, second_video].sort
  end
  
end
