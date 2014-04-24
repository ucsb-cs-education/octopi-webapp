require 'IdCrypt'
class SnapFile < ActiveRecord::Base
  #resourcify
  resourcify :student_roles, :role_cname => 'StudentRole'
  after_initialize :create_crypt

  # get the encoded record id
  def id_encoded
    @id_crypt.encode_id( self.id )
  end

# override of the base class method to ensure that raw user ids are not displayed in the url
  def to_param
    @id_crypt.encode_id( self.id )
  end

  protected
  def create_crypt
    @id_crypt = IdCrypt.new
  end
end
