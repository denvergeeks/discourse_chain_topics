# frozen_string_literal: true

# name: discourse_chain_topics
# about: This a discourse plugin which adds a feateur where it would be possible to chain topics. A topic can have other topic to be it's next or previous topic. 
# version: 0.0.1
# authors: Ghassanmas; https://github.com/ghassanmas https://ghaasan.blog
# url: https://github.com/zaatdev/discourse-chain-topics
# required_version: 2.7.0

enabled_site_setting :discourse_chain_topics

after_initialize do
    NEXT_TOPIC = 'next_topic'
    PREVIOUS_TOPIC = 'previous_topic'
    ## 
    # type:        step
    # number:      1
    # title:       Register the field
    # description: Where we tell discourse what kind of field we're adding. You
    #              can register a string, integer, boolean or json field.
    # references:  lib/plugins/instance.rb,
    #              app/models/concerns/has_custom_fields.rb
    ##
    register_topic_custom_field_type('next_topic', :integer)
    register_topic_custom_field_type('previous_topic', :integer)
    
    ##
    # type:        step
    # number:      2
    # title:       Add getter and setter methods
    # description: Adding getter and setter methods is optional, but advisable.
    #              It means you can handle data validation or normalisation, and
    #              it lets you easily change where you're storing the data.
    ##
    
    ##
    # type:        step
    # number:      2.1
    # title:       Getter method
    # references:  lib/plugins/instance.rb,
    #              app/models/topic.rb,
    #              app/models/concerns/has_custom_fields.rb
    ##
    add_to_class(:topic, NEXT_TOPIC.to_sym) do
      if !custom_fields[NEXT_TOPIC].nil?
        custom_fields[NEXT_TOPIC]
      else
        0
      end
    end
    add_to_class(:topic, PREVIOUS_TOPIC.to_sym) do
      if !custom_fields[PREVIOUS_TOPIC].nil?
        custom_fields[PREVIOUS_TOPIC]
      else
        0
      end
    end

    
    ##
    # type:        step
    # number:      2.2
    # title:       Setter method
    # references:  lib/plugins/instance.rb,
    #              app/models/topic.rb,
    #              app/models/concerns/has_custom_fields.rb
    ##
    add_to_class(:topic, "#{NEXT_TOPIC}=") do |value|
      custom_fields[NEXT_TOPIC] = value
    end
    
    add_to_class(:topic, "#{PREVIOUS_TOPIC}=") do |value|
     custom_fields[PREVIOUS_TOPIC] = value
    end

    ##
    # type:        step
    # number:      3
    # title:       Update the field when the topic is created or updated
    # description: Topic creation is contingent on post creation. This means that
    #              many of the topic update classes are associated with the post
    #              update classes.
    ##
    
    ##
    # type:        step
    # number:      3.1
    # title:       Update on topic creation
    # description: Here we're using an event callback to update the field after
    #              the first post in the topic, and the topic itself, is created.
    # references:  lib/plugins/instance.rb,
    #              lib/post_creator.rb
    ##
    on(:topic_created) do |topic, opts, user|
      topic.send("#{NEXT_TOPIC}=".to_sym, opts[NEXT_TOPIC.to_sym])
      topic.send("#{PREVIOUS_TOPIC}=".to_sym, opts[PREVIOUS_TOPIC.to_sym])
      topic.save!
    end
    
    ## 
    # type:        step
    # number:      3.2
    # title:       Update on topic edit
    # description: Update the field when it's updated in the composer when
    #              editing the first post in the topic, or in the topic title
    #              edit view.
    # references:  lib/plugins/instance.rb,
    #              lib/post_revisor.rb
    ##
    PostRevisor.track_topic_field(NEXT_TOPIC.to_sym) do |tc, value|
      tc.record_change(NEXT_TOPIC, tc.topic.send(NEXT_TOPIC), value)
      tc.topic.send("#{NEXT_TOPIC}=".to_sym, value.present? ? value : nil)
    end
  
    PostRevisor.track_topic_field(PREVIOUS_TOPIC.to_sym) do |tc, value|
      tc.record_change(PREVIOUS_TOPIC, tc.topic.send(PREVIOUS_TOPIC), value)
      tc.topic.send("#{PREVIOUS_TOPIC}=".to_sym, value.present? ? value : nil)
    end

    ##
    # type:        step
    # number:      4
    # title:       Serialize the field
    # description: Send our field to the client, along with the other topic
    #              fields.
    ##
    
    ## 
    # type:        step
    # number:      4.1
    # title:       Serialize to the topic
    # description: Send your field to the topic.
    # references:  lib/plugins/instance.rb,
    #              app/serializers/topic_view_serializer.rb
    ##
    add_to_serializer(:topic_view, NEXT_TOPIC.to_sym) do
      object.topic.send(NEXT_TOPIC)
    end
    add_to_serializer(:topic_view, PREVIOUS_TOPIC.to_sym) do
      object.topic.send(PREVIOUS_TOPIC)
    end

    ##
    # type:        step
    # number:      4.2
    # title:       Preload the field
    # description: Discourse preloads custom fields on listable models (i.e.
    #              categories or topics) before serializing them. This is to
    #              avoid running a potentially large number of SQL queries 
    #              ("N+1 Queries") at the point of serialization, which would
    #              cause performance to be affected.
    # references:  lib/plugins/instance.rb,
    #              app/models/topic_list.rb,
    #              app/models/concerns/has_custom_fields.rb
    ##

  
    ##
    # type:        step
    # number:      4.3
    # title:       Serialize to the topic list
    # description: Send your preloaded field to the topic list.
    # references:  lib/plugins/instance.rb,
    #              app/serializers/topic_list_item_serializer.rb
    ##

    DiscourseEvent.on(:topic_created) do |topic|
      if not topic.next_topic.to_i.zero?
        if topic.id == topic.next_topic
          topic.next_topic = 0
          topic.save
        else
          next_topic = Topic.find(topic.next_topic)
          next_topic.previous_topic = topic.id
          next_topic.save
        end
      end
    end
  
    DiscourseEvent.on(:post_edited) do |post, topic_changed|
      if topic_changed
        if not post.topic.next_topic.to_i.zero?
          if post.topic.id == post.topic.next_topic
            post.topic.update(next_topic: 0)
          else
            next_topic = Topic.find(post.topic.next_topic)
            next_topic.update(previous_topic: post.topic.id)
          end
        end
      end
    end

end