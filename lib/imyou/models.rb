module Imyou
  module Models
    def has_imyou?
      false
    end

    def has_imyou
      class_eval do

        has_many :imyou_nicknames, class_name: 'Imyou::Nickname', as: :model, dependent: :destroy
        scope :with_nicknames, -> { eager_load(:imyou_nicknames) }

        scope :match_by_nickname, ->(nickname) do
          with_nicknames.merge(
              Imyou::Nickname.where(Imyou::Nickname.arel_table[:name].eq(sanitize_sql_like(nickname)))
          )
        end

        scope :partial_match_by_nickname, ->(nickname) do
          with_nicknames.merge(
              Imyou::Nickname.where(Imyou::Nickname.arel_table[:name].matches("%#{sanitize_sql_like(nickname)}%"))
          )
        end

        def self.has_imyou?
          true
        end

        def nicknames
          self.imyou_nicknames.pluck(:name)
        end

        def remove_all_nicknames
          self.imyou_nicknames.delete_all
        end

        def add_nickname(nickname)
          self.imyou_nicknames.create!(name: nickname)
        end

        def remove_nickname(nickname)
          self.imyou_nicknames.find_by(name: nickname)&.destroy!
        end

        def nicknames=(new_nicknames)
          self.imyou_nicknames.where.not(name: new_nicknames).delete_all
          new_nicknames.each do |new_nickname|
            self.imyou_nicknames.find_or_create_by(name: new_nickname)
          end
        end
      end
    end
  end
end