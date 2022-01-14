# frozen_string_literal: true

require 'imyou/version'
require 'active_record'
require 'active_support/inflector'

module Imyou
  if defined?(ActiveRecord::Base)
    require 'imyou/models'
    require 'imyou/nickname'
    ActiveRecord::Base.extend Imyou::Models
  end
end
