# -*- encoding : utf-8 -*-
module Lolcommits
  class Loltext < Plugin
    DEFAULT_FONT_PATH = File.join(Configuration::LOLCOMMITS_ROOT, 'vendor', 'fonts', 'Lato.ttf')
    DEFAULT_LOGO_PATH = File.join(Configuration::LOLCOMMITS_ROOT, 'vendor', 'logos', 'Snapgit.png')

    def self.name
      'loltext'
    end

    # enabled by default (if no configuration exists)
    def enabled?
      !configured? || super
    end

    def run_postcapture
      debug 'Annotating image via MiniMagick'
      image = MiniMagick::Image.open(runner.main_image)
      annotate(image, :message, clean_msg(runner.message))
      image = add_logo(image, DEFAULT_LOGO_PATH)
      debug "Writing changed file to #{runner.main_image}"
      image.write runner.main_image
    end

    def annotate(image, type, string)
      debug("annotating #{type} text to image")

      image.combine_options do |c|
        c.strokewidth '2'
        c.interline_spacing '-9'
        c.stroke config_option(type, :stroke_color)
        c.fill config_option(type, :color)
        c.gravity position_transform(config_option(type, :position))
        c.pointsize runner.animate? ? 24 : config_option(type, :size)
        c.font config_option(type, :font)
        c.annotate '0', string
      end
    end

    def add_logo(image, logo_path)
      @logo = MiniMagick::Image.open(logo_path)

      padding = 5
      left = image[:width] - @logo[:width] - padding
      image.composite(@logo, 'png') do |c|
        c.compose 'Over'
        c.geometry "+#{left}+0"
      end
    end

    def configure_options!
      options = super
      # ask user to configure text options when enabling
      if options['enabled']
        puts '------------------------------------------------------'
        puts '  Text options '
        puts
        puts '  * blank options use the (default)'
        puts '  * use full absolute path to fonts'
        puts '  * valid positions are NE, NW, SE, SW, C (centered)'
        puts '  * colors can be hex #FC0 value or a string \'white\''
        puts '------------------------------------------------------'

        options[:message] = configure_sub_options(:message)
        options[:sha]     = configure_sub_options(:sha)
      end
      options
    end

    # TODO: consider this type of configuration prompting in the base Plugin
    # class, working with hash of defaults
    def configure_sub_options(type)
      print "#{type} text:\n"
      defaults = config_defaults[type]

      # sort option keys since different `Hash#keys` varys across Ruby versions
      defaults.keys.sort_by(&:to_s).reduce({}) do |acc, opt|
        print "  #{opt.to_s.tr('_', ' ')} (#{defaults[opt]}): "
        val = parse_user_input(STDIN.gets.strip)
        acc.merge(opt => val)
      end
    end

    def config_defaults
      {
        :message => {
          :font     => DEFAULT_FONT_PATH,
          :size     => 48,
          :position => 'SW',
          :color    => 'white',
          :stroke_color => 'black'
        }
      }
    end

    def config_option(type, option)
      default_option = config_defaults[type][option]
      if configuration[type]
        configuration[type][option] || default_option
      else
        default_option
      end
    end

    private

    # explode psuedo-names for text position
    def position_transform(position)
      case position
      when 'NE'
        'NorthEast'
      when 'NW'
        'NorthWest'
      when 'SE'
        'SouthEast'
      when 'SW'
        'SouthWest'
      when 'C'
        'Center'
      end
    end

    # do whatever is required to commit message to get it clean and ready for imagemagick
    def clean_msg(text)
      wrapped_text = word_wrap text
      escape_quotes wrapped_text
      escape_ats wrapped_text
    end

    # conversion for quotation marks to avoid shell interpretation
    # does not seem to be a safe way to escape cross-platform?
    def escape_quotes(text)
      text.gsub(/"/, "''")
    end

    def escape_ats(text)
      text.gsub(/@/, '\@')
    end

    # convenience method for word wrapping
    # based on https://github.com/cmdrkeene/memegen/blob/master/lib/meme_generator.rb
    def word_wrap(text, col = 20)
      wrapped = text.gsub(/(.{1,#{col + 4}})(\s+|\Z)/, "\\1\n")
      wrapped.chomp!
    end
  end
end
