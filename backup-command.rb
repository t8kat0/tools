#!/usr/bin/ruby

require 'fileutils'

module Tool

    class Command
        def execute()
            self.do_execute()
        end
    end

    class BackupCommand < Command
        def initialize(source_path, suffix = '_backup')
            @source_path = source_path
            @destination_path = source_path + suffix
        end

        def do_execute()
            self.do_copy()
        end
    end

    class BackupFileCommand < BackupCommand
        def do_copy()
            puts "copy file: #{@source_path} -> #{@destination_path}"
            FileUtils::copy_file(@source_path, @destination_path, { :preserve => true })
        end
    end

    class BackupDirectoryCommand < BackupCommand
        def do_copy()
            puts "copy directory: #{@source_path} -> #{@destination_path}"
            FileUtils::copy_entry(@source_path, @destination_path, { :preserve => true })
        end
    end

    class BackupCommandFactory
        def self.factory(source_path, suffix = nil)
            if suffix == nil
                suffix = '_backup'
            else
                suffix = '_' + suffix
            end
            unless FileTest::exist?(source_path)
                raise "target not found!! target=#{source_path}"
            end

            if FileTest::file?(source_path)
                BackupFileCommand.new(source_path, suffix)
            elsif FileTest::directory?(source_path)
                BackupDirectoryCommand.new(source_path, suffix)
            else
                raise 'target is not a file or directory!! target=#{source_path}'
            end
        end
    end
end

TARGET_PATH = ARGV[0]
# puts "TARGET_PATH: #{TARGET_PATH}"
unless TARGET_PATH
    puts 'ERROR!! TARGET_PATH is invalid!!'
    exit(false)
end

SUFFIX = ARGV[1]
# puts "SUFFIX: #{SUFFIX}"

command = Tool::BackupCommandFactory.factory(TARGET_PATH, SUFFIX)
command.execute()
