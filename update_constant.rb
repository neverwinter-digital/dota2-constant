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
ABILITY_NAME_BASE = 'DOTA_Tooltip_ability_'
TALENT_NAME_BASE = 'DOTA_Tooltip_ability_special_bonus_'
talent_urls = {
    npc_heroes_url: 'https://raw.githubusercontent.com/dotabuff/d2vpkr/master/dota/scripts/npc/npc_heroes.json',
    tooltip_ability_zh_url: 'https://raw.githubusercontent.com/dotabuff/d2vpkr/master/dota/resource/dota_schinese.json',
    tooltip_ability_en_url: 'https://raw.githubusercontent.com/dotabuff/d2vpkr/master/dota/resource/dota_english.json'
}

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

def update_talent_name_to_info_worker(info)
  talent_name_to_info = {}
  info = JSON.parse(info)

  info['lang']['Tokens'].each do |talent_name, talent_info|
    if talent_name.start_with?(TALENT_NAME_BASE)
      talent_name_to_info[talent_name[ABILITY_NAME_BASE.length, talent_name.length]] = talent_info
    end
  end
  talent_name_to_info
end

# talent name_en to info_en
# talent name_zh to info_zh
def update_talent_name_to_info(talent_urls)
  talent_name_to_info = {}
  info_en = request(URI(talent_urls[:tooltip_ability_en_url]))
  info_zh = request(URI(talent_urls[:tooltip_ability_zh_url]))
  talent_name_to_info_en = update_talent_name_to_info_worker(info_en)
  talent_name_to_info_zh = update_talent_name_to_info_worker(info_zh)

  talent_name_to_info_en.each do |talent_name, talent_info_en|
    talent_info_zh = talent_name_to_info_zh[talent_name]
    talent_name_to_info["#{talent_name}_zh"] = talent_info_zh
    talent_name_to_info["#{talent_name}_en"] = talent_info_en
  end
  talent_name_to_info
end

def update_talent_worker(talent_urls, talent_name_to_info, talent_name_to_id)
  hero_id_to_talent_info = {}
  npc_heroes = request(URI(talent_urls[:npc_heroes_url]))
  npc_heroes = JSON.parse(npc_heroes)
  npc_heroes['DOTAHeroes'].each do |hero_name, value|
    if hero_name != 'Version' && hero_name != 'npc_dota_hero_base'
      hero_id = value['HeroID']
      unless hero_id_to_talent_info.key?(hero_id)
        hero_id_to_talent_info[hero_id] = {}
      end
      for i in 0..7
        talent_name = value["Ability1#{i}"]
        talent_id = talent_name_to_id[talent_name]
        level = (i/2 + 2)*5
        side = i % 2 == 0 ? 'right' : 'left'
        hero_id_to_talent_info[hero_id][talent_id] = {
            :type => "level_#{level}_#{side}",
            :info_en => talent_name_to_info["#{talent_name}_en"],
            :info_zh => talent_name_to_info["#{talent_name}_zh"]
        }
      end
    end
  end
  hero_id_to_talent_info
end

def update_talent_name_to_id(ability_url)
  talent_name_to_id = {}
  abilities = request(URI(ability_url))
  abilities = JSON.parse(abilities)
  abilities['DOTAAbilities'].each do |ability_name, value|
    if ability_name != 'Version' && ability_name != 'ability_base' && ability_name.start_with?('special_bonus_')
      talent_name_to_id[ability_name] = value['ID']
    end
  end
  talent_name_to_id
end

# update json/talent_info.json
def update_talent(ability_url, talent_urls)
  talent_name_to_id = update_talent_name_to_id(ability_url)
  talent_name_to_info = update_talent_name_to_info(talent_urls)
  hero_id_to_talent_info = update_talent_worker(talent_urls, talent_name_to_info, talent_name_to_id)
  File.open('json/talent_info.json', 'w') do |f|
    f.write(hero_id_to_talent_info.to_json)
  end
end

def run_update_talent(urls, talent_urls)
  update_talent(urls[:npc_abilities], talent_urls)
end

def run_update_locales
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
end

def run_update_yml(urls)
  urls.each do |key, url|
    puts url
    uri = URI(url)
    filepath = "yml/#{key}.yml"
    request_and_save(uri, filepath)
  end
  update_abilities
end

def update_abilities
  ability_id_to_name = {}
  npc_abilities = YAML.load_file('yml/npc_abilities.yml')
  abilities = npc_abilities['DOTAAbilities']
  abilities.each do |key, value|
    if key != 'Version'
      ability_id_to_name[value['ID'].to_i] = key
    end
  end

  File.open('yml/abilities.yml', 'w') do |file|
    file.write ability_id_to_name.to_yaml
  end
end

# make them into single functions, since the slow internet limits us to run one function at a time
run_update_talent(urls, talent_urls)
run_update_locales
run_update_yml(urls)

