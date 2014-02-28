# Rafters v2 draft

* Sources are "query objects"
* Components are "view objects"
* Sources should be usable across multiple components
* Components should map source interfaces to template outlets

## Example

```ruby
  # app/sources/topics_source.rb

  class TopicsSource < Rafters::Source
    name :topics

    option :sort_by
    option :order

    def topics
      @topics ||= Topic.where(sort_by: options[:sort_by], order: options[:order])
    end
  end
```

```ruby
  # app/components/list_view/list_view_component.rb

  class ListViewComponent < Rafters::Component
    name :list_view

    option :with_author, default: true

    source :topics do
      map :topics, to: :collection do
        map :subject, to: :name
      end
    end
  end
```

```erb
  # app/components/list_view/views/list_view.html.erb

  <ul>
    <% collection.each do |item| %>
      <%= item.name %>
    <% end %>
  </ul>
```

```ruby
  # app/controllers/topics_controller.rb

  class TopicsController < ActionController::Base
    def index
      @topics = TopicsSource.new(sort_by: "created_at", order: "DESC")
    end
  end
```

```erb
  # app/views/topics/index.html.erb

  <%= render_component :list_view, source: @topics, options: { with_author: false } %>
```
