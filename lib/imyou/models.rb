module Imyou
  module Models
    def has_imyou?
      false
    end

    def has_imyou(name_column=nil)
      class_eval do

        has_many :imyou_nicknames, class_name: 'Imyou::Nickname', as: :model, dependent: :destroy
        scope :with_nicknames, -> { eager_load(:imyou_nicknames) }

        scope :match_by_nickname, ->(nickname, with_name_column: true) do
          if Gem::Version.new(ActiveRecord.version) >= Gem::Version.new(5)
            records = self.with_nicknames.where(Imyou::Nickname.arel_table[:name].eq(nickname))
            unless name_column.nil? || with_name_column == false
              records.or!(self.with_nicknames.where(name_column => nickname))
            end
          else
            arel_nickname_column = Imyou::Nickname.arel_table[:name]
            records = if name_column.nil? || with_name_column == false
                        self.with_nicknames.where(
                            arel_nickname_column.eq(nickname)
                        )
                      else
                        arel_name_column = self.arel_table[name_column]
                        self.with_nicknames.where(
                            arel_nickname_column.eq(nickname).or(
                                arel_name_column.eq(nickname)
                            )
                        )
                      end
          end
          records
        end

        scope :partial_match_by_nickname, ->(nickname, with_name_column: true) do
          if Gem::Version.new(ActiveRecord.version) >= Gem::Version.new(5)
            records = self.with_nicknames.where(Imyou::Nickname.arel_table[:name].matches("%#{sanitize_sql_like(nickname)}%"))
            unless name_column.nil? || with_name_column == false
              records.or!(self.with_nicknames.where(
                  self.arel_table[name_column].matches("%#{sanitize_sql_like(nickname)}%"))
              )
            end
          else
            arel_nickname_column = Imyou::Nickname.arel_table[:name]
            records = if name_column.nil? || with_name_column == false
                        self.with_nicknames.where(
                            arel_nickname_column.matches("%#{sanitize_sql_like(nickname)}%")
                        )
                      else
                        arel_name_column = self.arel_table[name_column]
                        self.with_nicknames.where(
                            arel_nickname_column.matches("%#{sanitize_sql_like(nickname)}%").or(
                                arel_name_column.matches("%#{sanitize_sql_like(nickname)}%")
                            )
                        )
                      end
          end
          records
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