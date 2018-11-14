require 'rails/generators/migration'

module Imyou
  class MigrationGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    desc "Generators migration for Imyou(imyous table)"

    def self.orm
      Rails::Generators.options[:rails][:orm]
    end

    def self.source_root
      File.join(File.dirname(__FILE__), 'templates', (orm.to_s unless orm.class.eql?(String)))
    end

    def self.orm_has_migration?
      [:active_record].include? orm
    end

    def self.next_migration_number(path)
      Time.now.utc.strftime("%Y%m%d%H%M%S")
    end

    def create_migration_file
      if self.class.orm_has_migration?
        migration_template 'migration.rb', 'db/migrate/imyou_migration.rb', migration_version: migration_version
      end
    end

    def migration_version
      if rails5?
        "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
      end
    end

    def rails5?
      Rails.version.start_with? '5'
    end
  end
end