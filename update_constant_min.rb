require 'httparty'
require 'pry'

class UpdateConstantMin
  def initialize
    init_heroes
    init_items
    init_abilities
  end

  def run
    update_heroes
    update_items
    update_abilities
    update_ability_id_to_hero_id
  end

  private
  def init_heroes
    @heroes_url = "https://raw.githubusercontent.com/dotabuff/d2vpkr/master/dota/scripts/npc/npc_heroes.json"
    @npc_dota_hero_ = 'npc_dota_hero_'
  end

  def init_items
    @items_url = "https://raw.githubusercontent.com/dotabuff/d2vpkr/master/dota/scripts/npc/items.json"
    @item_ = "item_"
  end

  def init_abilities
    @abilities_url = "https://raw.githubusercontent.com/dotabuff/d2vpkr/master/dota/scripts/npc/npc_abilities.json"
  end

  def update_abilities
    puts 'update abilities'
    ability_id_to_name = {}
    response = HTTParty.get(@abilities_url)
    json_body = JSON.parse(response.body)
    @abilities = json_body['DOTAAbilities']
    @abilities.each do |key, value|
      next if value.empty? || value['ID'].nil?
      ability_id_to_name[value['ID'].to_i] = key
    end
    save_hash_to_yml('yml_min/abilities.yml', ability_id_to_name)
  end

  def update_items
    puts 'update items'
    item_id_to_name = {}
    response = HTTParty.get(@items_url)
    json_body = JSON.parse(response.body)
    json_body['DOTAAbilities'].each do |key, value|
      next if value['ID'].nil?
      item_id_to_name[value['ID'].to_i] = key[@item_.length..-1]
    end
    save_hash_to_yml('yml_min/items.yml', item_id_to_name)
  end

  def update_heroes
    puts 'update heroes'
    hero_id_to_name = {}
    response = HTTParty.get(@heroes_url)
    json_body = JSON.parse(response.body)
    @heroes = json_body['DOTAHeroes']
    @heroes.each do |key, value|
      next if value['HeroID'].nil?
      hero_id_to_name[value['HeroID'].to_i] = key[@npc_dota_hero_.length..-1]
    end
    save_hash_to_yml('yml_min/heroes.yml', hero_id_to_name)
  end

  def update_ability_id_to_hero_id
    ability_id_to_hero_id = {}

    @abilities.each do |key, value|
      next if value.empty? || value['ID'].nil?
      hero_key = "npc_dota_hero_#{key.split('_')[0]}"
      next unless @heroes.key?(hero_key)
      ability_id_to_hero_id[value['ID']] = @heroes[hero_key]['HeroID']
    end
    save_hash_to_yml('yml_min/ability_id_to_hero_id.yml', ability_id_to_hero_id)
  end

  def save_hash_to_yml(file_path, data)
    File.open(file_path, 'wb') do |file|
      file.write data.to_yaml
    end
  end
end

UpdateConstantMin.new.run
