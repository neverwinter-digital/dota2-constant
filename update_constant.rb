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

urls = { regions: 'https://raw.githubusercontent.com/dotabuff/d2vpkr/master/dota/scripts/regions.json',
         npc_abilities: 'https://raw.githubusercontent.com/dotabuff/d2vpkr/master/dota/scripts/npc/npc_abilities.json',
         items_games: 'https://raw.githubusercontent.com/dotabuff/d2vpkr/master/dota/scripts/items/items_game.json',
         leagues: 'https://raw.githubusercontent.com/dotabuff/d2vpkr/master/dota/scripts/items/leagues.json',
				 abilities: 'https://raw.githubusercontent.com/odota/dotaconstants/master/json/ability_ids.json'}

DOTA2_API_KEY = 'A72DE7D7BE9870C8DA671D67941CCAA7'
API_BASE_URL = 'https://api.steampowered.com/IDOTA2Match_570'
API_URLS = {
  get_league: "#{API_BASE_URL}/GetLeagueListing/v1"
}

live_url = { uniqueusers: 'http://www.dota2.com/jsfeed/uniqueusers' }

def get_pediadata(type, lang_code)
  uri = URI('http://www.dota2.com/jsfeed/heropediadata')
  params = {:l=>LANGUAGES[lang_code], :feeds=>PEDIA_TYPES[type]}
  uri.query = URI.encode_www_form(params)
  filepath = "locales/#{lang_code}/#{type}.yml"
  request_and_save(uri, filepath)
end

def get_league(lang_code)
  uri = URI(API_URLS[:get_league])
  params = {:language=>lang_code, :format=>'json', :key => DOTA2_API_KEY}
  uri.query = URI.encode_www_form(params)
  filepath = "locales/#{lang_code}/league_id_to_name.yml"
  tables = {}
  data = JSON.parse(request(uri))
  data['result']['leagues'].each do |league|
    tables[league['leagueid']] = league['name']
  end
  save_json_to_file(filepath, tables)
end

def get_jsfeed(jsfeed,lang_code)
  uri = URI(JSFEEDS[jsfeed])
  params = {:l=>LANGUAGES[lang_code]}
  uri.query = URI.encode_www_form(params)
  filepath = "locales/#{lang_code}/#{jsfeed}.yml"
  request_and_save(uri, filepath)
end

def request(uri)
  response = Net::HTTP.get_response(uri)
  return response.body
end

def save_json_to_file(filepath, data)
  File.open(filepath,'wb') do |file|
    file.write data.to_yaml
  end
end

def request_and_save(uri, filepath)
  response = Net::HTTP.get_response(uri)
  File.open(filepath,'wb') do |file|
    file.write JSON.parse(response.body).to_yaml
  end if response.is_a?(Net::HTTPSuccess)
end

LANGUAGES.keys.each do |lang_code|
  FileUtils.mkdir_p "locales/#{lang_code}"

  #JSFEEDS.keys.each do |jsfeed|
  #  get_jsfeed(jsfeed, lang_code)
  #end

  #PEDIA_TYPES.keys.each do |type|
  #  get_pediadata(type, lang_code)
  #end

  #get_league(lang_code)

end

urls.each do |key, url|
  uri = URI(url)
  filepath = "yml/#{key}.yml"
  request_and_save(uri, filepath)
end
