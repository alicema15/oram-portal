# == Schema Information
#
# Table name: user_roles
#
#  id            :integer          not null, primary key
#  name          :string
#  resource_id   :integer
#  resource_type :string
#  created_at    :datetime
#  updated_at    :datetime
#

class UserRole < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => :users_user_roles

  belongs_to :resource,
             :polymorphic => true

  validates :resource_type,
            :inclusion => { :in => Rolify.resource_types },
            :allow_nil => true

  scopify

  def capitalize_name
    name.capitalize
  end
end