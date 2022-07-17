Note: This plugin still in under development.

# **Discourse Topic Chain** Plugin

This a discourse plugin which adds a feature where it would be possible to chain topics. A topic can have other topic to be it's next or previous topic. 

## Example Usage and Features

This plugin makes it possible to chain topic. Chaining in this context means a topic could have a previous or/and next topic. 

Currently this plugin allows to set a next topic for a particular topic. 

Consider the scenario, where you have the following topics. 

Topic guildline part 1 -> Topic guildline part 2


Using this plugin you can; 

 _Edit(Also works when creating) Topic part 1 to designate topic part 2 as it's next._

The outcomes of the following: 
1. Topic part 1 will link to topic part 2 as **its next topic**
2. Topic part 2 will link to topic part 1 as **its previous topic** 

Point 1 and 2 above are accomplished by appending the **`topic-title`** theme.

Also when you are in topic part 1 you could you use the right arrow ">" to go topic part 2. Similarly you use left arrow "<" to go from part 2 to part 1. 

## Installing

To install this plugin on your discourse forum you follow the following standard installation guide: https://meta.discourse.org/t/install-plugins-in-discourse/19157 


## Project next milestones:
 
- Do refactoring.
- Add functionality so that its possible to set previous topic manually.  
- Tidy up the UX/UI.
- Write tests.

## Acknowledgment
- This project was boostrapped from: https://github.com/discourse/discourse-plugin-skeleton
- This project was influenced by: https://github.com/pavilionedu/discourse-topic-custom-fields 

## Support 
For support running this discourse plugin or any general support with discourse feel free to reach me at ghassan@zaat.dev 
