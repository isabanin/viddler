module Viddler
  
  # Raised when response from Viddler contains absolutely no data
  class EmptyResponseError < ViddlerError #:nodoc:
  end
  
  # Raised when response from Viddler contains an error
  class ResponseError < ViddlerError #:nodoc:
    def initialize(message)
      super message
    end
  end
  
  # Class used to send requests over http to Viddler API.
  class Request #:nodoc:
    
    API_URL = 'http://api.viddler.com/rest/v1/'
  
    attr_accessor :url, :http_method, :response
    attr_reader :params
  
    def initialize(http_method, method) #:nodoc:
      @http_method = http_method.to_s
      @url = API_URL
      self.params = {:method => viddlerize(method)}    
    end
    
    # Use this method to setup your request's payload and headers.
    #
    # Example:
    #
    #   request.set :headers do |h|
    #     h.content_type = 'application/ufo'
    #   end
    #
    #   request.set :params do |p|
    #     p.sessionid = '12323'
    #     p.api_key   = '13123
    #   end
    # 
    def set(container, &declarations)
      struct = OpenStruct.new
      declarations.call(struct)
      send("#{container}=", struct.table)
    end
    
    # Send http request to Viddler API.
    def run(&block)
      if block_given?
        set(:params, &block)
      end

      c = Curl::Easy.new(url)
      c.headers['Accept'] = 'application/xml'
    
      if post? and multipart?
        c.multipart_form_post = true
        c.http_post(*build_params)
      else
        c.url = url_with_params
        c.perform
      end

      self.response = parse_response(c.body_str)
    end
  
    private

    def build_params
      f = []
      t = []
      params.each do |key, value| 
        if value.is_a? File
          f << Curl::PostField.file(key.to_s, value.path, File.basename(value.path))
        else
          t << Curl::PostField.content(key.to_s, value.to_s)
        end
      end
      t + f
    end
  
    def parse_response(raw_response)
      raise EmptyResponseError if raw_response.blank?
      response_hash = Hash.from_xml(raw_response)
      if response_error = response_hash['error']
        raise ResponseError.new(viddler_error_message(response_error))
      end
      response_hash
    end
  
    def url_with_params
      self.url + '?' + params.to_query
    end
  
    def viddlerize(name)
      if name.include?('viddler.')
        name
      else
        'viddler.' + name
      end
    end
    
    def params=(hash) #:nodoc:
      @params ||= Hash.new
      @params.update(hash)
    end
  
    def multipart? #:nodoc:
      if params.find{|k,v| v.is_a?(File)} then true else false end
    end
  
    def post? #:nodoc:
      http_method == 'post'
    end
    
    def viddler_error_message(response_error)
      description = response_error['description'] || ''
      details = response_error['details'] || ''      
      code = response_error['code'] || ''
      
      details = ": #{details};" unless details.empty?
      code = " [code: #{code}]" unless code.empty?
      %Q[#{description}#{details}#{code}]
    end
  
  end
end
