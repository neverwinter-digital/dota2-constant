class Dota2::Constants

  attr_reader :mapping

  def initialize
    @mapping = Hash.new
    load_stats
    load_locales
    @mapping.freeze
  end

  def load_stats
    manifest['stats'].each do |filename|
      @mapping[filename.to_sym] = YAML.load_file(stat_filepath(filename)).freeze
    end
  end

  def load_locales
    manifest['locales'].each do |lang_code, filenames|
      @mapping[lang_code.to_sym] = Hash.new
      filenames.each do |filename|
        @mapping[lang_code.to_sym][filename.to_sym] = YAML.load_file(locale_filepath(lang_code, filename)).freeze
      end
    end
  end

  def locale_filepath(lang_code, filename)
    File.join(Dota2::Constants.root ,'locales',"#{lang_code}/#{filename}.yml")
  end

  def stat_filepath(filename)
    File.join(Dota2::Constants.root, 'yml', "#{filename}.yml")
  end

  def manifest
    path = File.join(Dota2::Constants.root, 'manifest.yml')
    YAML.load_file(path).freeze
  end

  def self.root
    File.join(Rails.root, '/lib/constants/dota2')
  end

end
