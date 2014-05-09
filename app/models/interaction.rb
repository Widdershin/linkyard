class Interaction < ActiveRecord::Base
  belongs_to :user
  has_many :link_interactions

  validates :type, :presence => true
end