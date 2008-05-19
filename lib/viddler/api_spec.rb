module Viddler #:nodoc:
  
  class ApiSpec #:nodoc:
    
    USERS_REGISTER_ATTRS = {
      :required => [
        :user, 
        :email, 
        :fname, 
        :lname, 
        :password, 
        :question, 
        :answer, 
        :lang, 
        :termsaccepted
      ],
      :optional => [
        :company
      ]
    }
    
    USERS_SETPROFILE_ATTRS = {
      :optional => [
        :first_name,
        :last_name,
        :about_me,
        :birthdate,
        :gender,
        :company,
        :city
      ]
    }
    
    USERS_SETOPTIONS_ATTRS = {
      :optional => [
        :show_account,
        :tagging_enabled,
        :commenting_enabled,
        :show_related_videos,
        :embedding_enabled,
        :clicking_through_enabled,
        :email_this_enabled,
        :trackbacks_enabled,
        :favourites_enabled,
        :custom_logo_enabled
      ]
    }
    
    VIDEOS_UPLOAD_ATTRS = {
      :required => [
        :title,
        :description,
        :tags,
        :file,
        :make_public
      ]
    }
    
    VIDEOS_SETDETAILS_ATTRS = {
      :optional => {
        :title,
        :description,
        :tags,
        :view_perm,
        :view_users,
        :view_use_secret,
        :embed_perm,
        :embed_users,
        :commenting_perm,
        :tagging_perm,
        :download_perm,
        :download_users
      }
    }
    
    def self.check_attributes(viddler_method, attributes)
      valid_attributes = viddler_method_to_const(viddler_method)
      required = valid_attributes[:required] || Array.new
      optional = valid_attributes[:optional] || Array.new
      
      attributes.assert_valid_keys(required + optional)
      attributes.assert_required_keys(required)
    end
    
    protected
    
    def self.viddler_method_to_const(method)
      const_name = method.gsub('.', '_').upcase
      const_get("#{const_name}_ATTRS")
    end
    
  end
  
end