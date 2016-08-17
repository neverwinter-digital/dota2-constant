#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'fileutils'
require 'yaml'

LANGUAGES = { en: 'english',
              zh: 'schinese',
              ru: 'russian',
              kr: 'korean'}

JSFEEDS = { items: 'http://www.dota2.com/jsfeed/itemdata',
            abilities: 'http://www.dota2.com/jsfeed/abilitydata',
            heropickerdata: 'http://www.dota2.com/jsfeed/heropickerdata'}

PEDIA_TYPES = { itempedia: 'itemdata',
                heropedia: 'herodata',
                abilitypedia: 'abilitydata'}

urls = { uniqueusers: 'http://www.dota2.com/jsfeed/uniqueusers',
         regions: 'https://raw.githubusercontent.com/dotabuff/d2vpkr/master/dota/scripts/regions.json',
         npc_abilities: 'https://raw.githubusercontent.com/dotabuff/d2vpkr/master/dota/scripts/npc/npc_abilities.json'}

def get_pediadata(type, lang_code)
  uri = URI('http://www.dota2.com/jsfeed/heropediadata')
  params = {:l=>LANGUAGES[lang_code], :feeds=>PEDIA_TYPES[type]}
  uri.query = URI.encode_www_form(params)
  filepath = "locales/#{lang_code}/#{type}.yml"
  request_and_save(uri, filepath)
end

def get_jsfeed(jsfeed,lang_code)
  uri = URI(JSFEEDS[jsfeed])
  params = {:l=>LANGUAGES[lang_code]}
  uri.query = URI.encode_www_form(params)
  filepath = "locales/#{lang_code}/#{jsfeed}.yml"
  request_and_save(uri, filepath)
end

def request_and_save(uri, filepath)
  response = Net::HTTP.get_response(uri)
  File.open(filepath,'wb') do |file|
    file.write JSON.parse(response.body).to_yaml
  end if response.is_a?(Net::HTTPSuccess)
end

LANGUAGES.keys.each do |lang_code|
  FileUtils.mkdir_p "locales/#{lang_code}"

  JSFEEDS.keys.each do |jsfeed|
    get_jsfeed(jsfeed, lang_code)
  end

  PEDIA_TYPES.keys.each do |type|
    get_pediadata(type, lang_code)
  end

end

urls.each do |key, url|
  uri = URI(url)
  filepath = "yml/#{key}.yml"
  request_and_save(uri, filepath)
end

