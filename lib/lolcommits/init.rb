# -*- encoding : utf-8 -*-
module Lolcommits
  class Init
    require 'lolcommits'
    require 'fileutils'
    require 'tmpdir'

    def self.run_setup(lolcommits_binary)
      require 'io/console'
      @lolcommits_binary = lolcommits_binary
      ENV["LOLCOMMITS_INIT_PARAMS"] = "--delay 1" # since that's required on the Mac

      puts "This setup will run through the necessary steps to get you up and running"
      puts "Please follow the wizard to authenticate Twitter and Gravatar"
      puts "If you don't want to use Gravatar, just don't provide any values"
      puts "Confirm with Enter"
      STDIN.getch

      Dir.mktmpdir do |tmp_dir|
        `git init` # just to make lolcommits believe we're in a git folder
        result = self.request_auth_tokens

        if result == false
          puts "Setup failed - please try again"
          abort
        end
        @config_path = result
      end

      puts "-"
      puts "Successfully generated keys... now setting up your git projects:"
      puts "-"

      puts "Do you want snapgit to automatically enable itself for all local git repositories? (y/n)"
      if STDIN.getch.strip == "y"
        self.enable_for_all_projects
      else
        if File.directory?(".git")
          puts "Do you want to enable snapgit just for the local directory? (y/n)"
          if STDIN.getch.strip == "y"
            enable_for_local_folder
            return
          end
        else
          puts "-"
          puts "Please navigate to the project you want to enable snapgit for"
          puts "and run `snapgit init`"
          abort
        end
      end
    end

    # @return (success or not)
    def self.request_auth_tokens
      $stdout.sync = true
      Configuration.new.do_configure!("snapgit")
    end

    def self.enable_for_local_folder
      enable_for_project(".")
      puts "Successfully enabled snapgit 🎉"
    end

    def self.enable_for_all_projects
      projs = git_projects
      puts projs
      puts "Do you want to enable snapgit for all those repos? (y/n)"
      abort unless STDIN.getch.strip == "y"

      projs.each do |current|
        enable_for_project(current)
      end
      puts "Successfully enabled snapgit for #{projs.count} projects 🎉"
    end

    def self.enable_for_project(path)
      puts "Enabling snapgit for '#{File.expand_path(path)}'..."
      Dir.chdir(path) do
        # Add the `lolcommits --capture` to the post-hook
        Lolcommits::Installation.do_enable

        # Copy the config.yml to the ~/.lolcommits/[project] folder
        to_path = Lolcommits::Configuration.new.loldir # this will use the current dir by default
        FileUtils.cp(@config_path, to_path)
      end
    end

    def self.git_projects
      puts "Searching for git repos"
      # We're using README.md assuming that every repo has one
      # This is due to Spotlight not finding hidden files (.git)
      potential = `mdfind -name "README.md" -onlyin ~`.split("\n")

      # After we have all README.md we look for a .git folder in
      # each of those
      potential.collect do |current|
        path = File.expand_path("..", current)
        if File.directory?(File.join(path, ".git"))
          path
        else
          nil
        end
      end.delete_if { |a| a.nil? }
    end
  end
end

# Cheap monkey patching to not get any output when enabling lolcommits
module Lolcommits
  class Installation
    def self.info(str)
    end
  end
end