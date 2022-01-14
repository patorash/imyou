# frozen_string_literal: true

module Imyou
  class Nickname < ::ActiveRecord::Base
    self.table_name = 'imyou_nicknames'
    belongs_to :model, polymorphic: true

    scope :by_type, ->(klass) { where(model_type: klass.name) }
    scope :default_order, -> { order(id: :asc) }
    default_scope { default_order }

    validates :name, presence: true
    validates_uniqueness_of :name, scope: %i[model_id model_type]
  end
end
