module Imyou
  module Models
    def has_imyou?
      false
    end

    def has_imyou(name_column=nil)
      class_eval do

        has_many :imyou_nicknames, -> { order(id: :asc) }, class_name: 'Imyou::Nickname', as: :model, dependent: :destroy
        scope :with_nicknames, -> { preload(:imyou_nicknames) }

        scope :match_by_nickname, ->(nickname, with_name_column: true) do
          if Gem::Version.new(ActiveRecord.version) >= Gem::Version.new(5)
            records = self.left_outer_joins(:imyou_nicknames).where(Imyou::Nickname.arel_table[:name].eq(nickname))
            unless name_column.nil? || with_name_column == false
              records.or!(self.left_outer_joins(:imyou_nicknames).where(name_column => nickname))
            end
          else
            joined_records = self.joins(<<~SQL
              LEFT OUTER JOIN #{Imyou::Nickname.quoted_table_name}
              ON
                #{Imyou::Nickname.quoted_table_name}.#{connection.quote_column_name(:model_id)} = #{self.quoted_table_name}.#{connection.quote_column_name(:id)}
                AND
                #{Imyou::Nickname.quoted_table_name}.#{connection.quote_column_name(:model_type)} = #{connection.quote(self.name)}
            SQL
            )
            arel_nickname_column = Imyou::Nickname.arel_table[:name]
            records = if name_column.nil? || with_name_column == false
                        joined_records.where(
                            arel_nickname_column.eq(nickname)
                        )
                      else
                        arel_name_column = self.arel_table[name_column]
                        joined_records.where(
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
            records = self.left_outer_joins(:imyou_nicknames).where(Imyou::Nickname.arel_table[:name].matches("%#{sanitize_sql_like(nickname)}%"))
            unless name_column.nil? || with_name_column == false
              records.or!(self.left_outer_joins(:imyou_nicknames).where(
                  self.arel_table[name_column].matches("%#{sanitize_sql_like(nickname)}%"))
              )
            end
          else
            joined_records = self.joins(<<~SQL
              LEFT OUTER JOIN #{Imyou::Nickname.quoted_table_name}
              ON
                #{Imyou::Nickname.quoted_table_name}.#{connection.quote_column_name(:model_id)} = #{self.quoted_table_name}.#{connection.quote_column_name(:id)}
                AND
                #{Imyou::Nickname.quoted_table_name}.#{connection.quote_column_name(:model_type)} = #{connection.quote(self.name)}
            SQL
            )
            arel_nickname_column = Imyou::Nickname.arel_table[:name]
            records = if name_column.nil? || with_name_column == false
                        joined_records.where(
                            arel_nickname_column.matches("%#{sanitize_sql_like(nickname)}%")
                        )
                      else
                        arel_name_column = self.arel_table[name_column]
                        joined_records.where(
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
          if new_record?
            self.imyou_nicknames.map(&:name)
          else
            self.imyou_nicknames.pluck(:name)
          end
        end

        def remove_all_nicknames
          self.imyou_nicknames.delete_all
        end

        def add_nickname(nickname)
          if new_record?
            self.imyou_nicknames.build(name: nickname)
          else
            self.imyou_nicknames.find_or_create_by(name: nickname)
          end
        end

        def remove_nickname(nickname)
          if new_record?
            array = self.imyou_nicknames.to_a.delete_if do |imyou_nickname|
              imyou_nickname.name == nickname
            end
            self.imyou_nicknames.replace(array)
            true
          else
            self.imyou_nicknames.find_by(name: nickname)&.destroy!
          end
        end

        def nicknames=(new_nicknames)
          if new_record?
            new_nicknames&.each do |new_nickname|
              self.imyou_nicknames.build(name: new_nickname)
            end
          else
            if new_nicknames.blank?
              self.imyou_nicknames.delete_all
            else
              self.imyou_nicknames.where.not(name: new_nicknames).delete_all
              new_nicknames.each do |new_nickname|
                self.imyou_nicknames.find_or_create_by(name: new_nickname)
              end
            end
          end
        end
      end
    end
  end
end