# dota2-constant

## Dota2 Leauges

The leagues' zh_name, en_name are more frequently asked by API. And we saved it to database along with the league logo url.

To crawl leagues' data, we normally start a cron job in DC/OS, all the info will be saved into database, and logos will be saved into aliyun OSS.

## Dota2 Teams

The team's info will be downloaded along with each match.

## Dota2 Hero/ Hero Abilities

We will do it mannually. As noramlly it won't change too much.

## Others

We do it mannually. 

## Changes for each patch
### Always
  - `yml/patch.yml` updates patch name and time
### Common
  - `json/talent_info.json` heroes' talent tree updates
  - `locales` Dota 2 info in different languages
  - `yml/abilities.yml` ability id to talent name, if there are newly added talents or abilities
  - `yml/items_games.yml` if there are item changes
  - `yml/leagues.yml` newly added leagues
  - `yml/npc_abilities.yml` if there are hero abilities changes
### Rare
  - `json/ability_id_to_hero_id.json` only when a hero's ability tree changes
  - `yml/items.yml`  only when there are newly added items
