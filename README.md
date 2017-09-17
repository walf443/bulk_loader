# BulkLoader

## Example

```ruby
# app/models/post.rb

class Post < ApplicationRecord
  include BulkLoader::DSL

  bulk_loader :comment_count, :id, default: 0 do |ids|
    Comment.where(id: ids).group(:post_id).count
  end
end

```

You can use followings:

```ruby
# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  def index
    @posts = Post.limit(10)

    # load comment_count blocks with mapping by #id
    # you can avoid N+1 queries.
    Post.bulk_loader.load(:comment_count, @posts)

    render(json: @posts.map {|post| { id: post.id, comment_count: post.comment_count } })
  end
end
```

## Description

BulkLoader::DSL only create bulk\_loader class method and bulk\_loader method.
So you can use any object that is not ActiveRecord.

### Defining bulk\_loader method

If you include BulkLoader::DSL, you can use bulk\_loader class method.

```ruby
class YourModel
  include BulkLoader::DSL

  bulk_loader :name, :mapped_key, default: nil do |mapped_keys|
    # something with mapped_keys
    {
      mapped_key => value, # you should return Hash that has mapped_key as key.
    }
  end
end
```

that create a instance method that name is :name.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bulk_loader'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bulk_loader

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/walf443/bulk_loader.
