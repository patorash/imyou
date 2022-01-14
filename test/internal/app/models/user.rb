class User < ActiveRecord::Base
  has_imyou :name

  validates :name, presence: true
end
