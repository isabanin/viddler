require 'rest_client'

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
    DEFAULT_HEADERS = {:accept => 'application/xml', :content_type => 'application/x-www-form-urlencoded'}
  
    attr_accessor :url, :http_method, :response, :body
    attr_reader :headers, :params
  
    def initialize(http_method, method) #:nodoc:
      @http_method = http_method.to_s
      @url = API_URL
      self.params = {:method => viddlerize(method)}    
      self.headers = DEFAULT_HEADERS
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
    
      if post? and multipart?
        put_multipart_params_into_body
      else
        put_params_into_url
      end    
      request = RestClient::Request.execute(
         :method => http_method, 
         :url => url, 
         :headers => headers, 
         :payload => body
       )
       self.response = parse_response(request)
    end
  
    private
  
    def parse_response(raw_response)
      raise EmptyResponseError if raw_response.blank?
      response_hash = Hash.from_xml(raw_response)
      if response_error = response_hash['error']
        raise ResponseError.new(viddler_error_message(response_error))
      end
      response_hash
    end
  
    def put_multipart_params_into_body
      multiparams = MultipartParams.new(params)
      self.body = multiparams.body
      self.headers = {:content_type => multiparams.content_type}
    end
  
    def put_params_into_url
      self.url = API_URL + '?' + params.to_query
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
  
    def headers=(hash) #:nodoc:
      @headers ||= Hash.new
      @headers.update(hash)
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