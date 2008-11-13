module Viddler
  # This class wraps Viddler's comment's information.
  class Comment
  
    attr_accessor :id, :author, :text, :time, :timepoint
  
    def initialize(attributes={}) #:nodoc:
      a = attributes
      @id     = a['id']      
      @author = a['author']
      @text   = a['text']      
      @time   = Time.at(fix_unix_time(a['time']))
      @timepoint = a['add_timepoint'].to_i / 1000
    end
    
    private
    
    # For unknown reason Viddler API returns wrong unix time with 3 superfluous zeros at the end.
    def fix_unix_time(viddler_time) #:nodoc:
      viddler_time.to_i / 1000
    end
  
  end
end
