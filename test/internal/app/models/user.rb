# frozen_string_literal: true

class User < ActiveRecord::Base
  has_imyou :name

  validates :name, presence: true
end
