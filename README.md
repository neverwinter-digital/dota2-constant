### update_constant_min
  Dotabuff有定时从客户端解析数据为json文件，进行上传到Github
  
  - [英雄](https://raw.githubusercontent.com/dotabuff/d2vpkr/master/dota/scripts/npc/npc_heroes.json)
  - [物品](https://raw.githubusercontent.com/dotabuff/d2vpkr/master/dota/scripts/npc/items.json)
  - [技能](https://raw.githubusercontent.com/dotabuff/d2vpkr/master/dota/scripts/npc/npc_abilities.json)
  
  `update_constant_min.rb`解析这些json文件并生成了相关的yml文件存储在`active_yml`文件夹下

### active_yml
当前在用的yml文件
  - `filtered_abilities.yml`
    - 不展示的一些技能，主要是toggle类的

 