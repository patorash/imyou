# frozen_string_literal: true

module Imyou
  module Models
    def has_imyou?
      false
    end

    def has_imyou(name_column = nil)
      klass = self
      class_eval do
        has_many :imyou_nicknames, lambda {
                                     order(id: :asc)
                                   }, class_name: 'Imyou::Nickname', as: :model, dependent: :destroy

        accepts_nested_attributes_for :imyou_nicknames,
                                      allow_destroy: true,
                                      reject_if: ->(attributes) { attributes['name'].blank? }

        scope :with_nicknames, -> { preload(:imyou_nicknames) }

        klass.define_singleton_method(:match_by_nickname) do |nickname, with_name_column: true|
          if Gem::Version.new(ActiveRecord.version) >= Gem::Version.new(5)
            records = left_outer_joins(:imyou_nicknames).where(Imyou::Nickname.arel_table[:name].eq(nickname))
            unless name_column.nil? || with_name_column == false
              records.or!(left_outer_joins(:imyou_nicknames).where(name_column => nickname))
            end
          else
            joined_records = joins(<<~SQL)
              LEFT OUTER JOIN #{Imyou::Nickname.quoted_table_name}
              ON
                #{Imyou::Nickname.quoted_table_name}.#{connection.quote_column_name(:model_id)} = #{quoted_table_name}.#{connection.quote_column_name(:id)}
                AND
                #{Imyou::Nickname.quoted_table_name}.#{connection.quote_column_name(:model_type)} = #{connection.quote(name)}
            SQL
            arel_nickname_column = Imyou::Nickname.arel_table[:name]
            records = if name_column.nil? || with_name_column == false
                        joined_records.where(
                          arel_nickname_column.eq(nickname)
                        )
                      else
                        arel_name_column = arel_table[name_column]
                        joined_records.where(
                          arel_nickname_column.eq(nickname).or(
                            arel_name_column.eq(nickname)
                          )
                        )
                      end
          end
          records
        end

        klass.define_singleton_method(:partial_match_by_nickname) do |nickname, with_name_column: true|
          if Gem::Version.new(ActiveRecord.version) >= Gem::Version.new(5)
            records = left_outer_joins(:imyou_nicknames).
                      where(Imyou::Nickname.arel_table[:name].
                      matches("%#{sanitize_sql_like(nickname)}%", '\\'))
            unless name_column.nil? || with_name_column == false
              records.or!(left_outer_joins(:imyou_nicknames).where(
                            arel_table[name_column].matches("%#{sanitize_sql_like(nickname)}%", '\\')
                          ))
            end
          else
            joined_records = joins(<<~SQL)
              LEFT OUTER JOIN #{Imyou::Nickname.quoted_table_name}
              ON
                #{Imyou::Nickname.quoted_table_name}.#{connection.quote_column_name(:model_id)} = #{quoted_table_name}.#{connection.quote_column_name(:id)}
                AND
                #{Imyou::Nickname.quoted_table_name}.#{connection.quote_column_name(:model_type)} = #{connection.quote(name)}
            SQL
            arel_nickname_column = Imyou::Nickname.arel_table[:name]
            records = if name_column.nil? || with_name_column == false
                        joined_records.where(
                          arel_nickname_column.matches("%#{sanitize_sql_like(nickname)}%", '\\')
                        )
                      else
                        arel_name_column = arel_table[name_column]
                        joined_records.where(
                          arel_nickname_column.matches("%#{sanitize_sql_like(nickname)}%", '\\').or(
                            arel_name_column.matches("%#{sanitize_sql_like(nickname)}%", '\\')
                          )
                        )
                      end
          end
          records
        end

        alias_method :save_with_nicknames, :save
        alias_method :save_with_nicknames!, :save!

        def self.has_imyou?
          true
        end

        def nicknames
          if new_record?
            imyou_nicknames.map(&:name)
          else
            imyou_nicknames.pluck(:name)
          end
        end

        def remove_all_nicknames
          imyou_nicknames.delete_all
        end

        def add_nickname(nickname)
          if new_record?
            imyou_nicknames.build(name: nickname)
          else
            imyou_nicknames.find_or_create_by(name: nickname)
          end
        end

        def remove_nickname(nickname)
          if new_record?
            array = imyou_nicknames.to_a.delete_if do |imyou_nickname|
              imyou_nickname.name == nickname
            end
            imyou_nicknames.replace(array)
          else
            imyou_nicknames.find_by(name: nickname)&.destroy!
          end
          true
        end

        def nicknames=(new_nicknames)
          if new_record?
            new_nicknames&.each { |new_nickname| imyou_nicknames.build(name: new_nickname) }
          elsif new_nicknames.blank?
            remove_all_nicknames
          else
            imyou_nicknames.where.not(name: new_nicknames).delete_all
            new_nicknames.each { |new_nickname| imyou_nicknames.find_or_create_by(name: new_nickname) }
          end
        end
      end
    end
  end
end
