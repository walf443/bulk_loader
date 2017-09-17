require File.join(File.expand_path(File.join(__dir__, '..')), 'lib', 'bulk_loader')
require 'singleton'
require 'set'

class CommentRepositoy
  include Singleton

  def initialize
    @comments = []
  end

  def push(comment)
    @comments.push(comment)
  end

  def load
    @comments
  end
end

class Comment
  attr_accessor :id, :post_id, :user_id

  def initialize(id:, post_id:, user_id:)
    self.id = id
    self.user_id = user_id
    self.post_id = post_id
  end
end

class Post
  include BulkLoader::DSL
  attr_accessor :id

  bulk_loader :comment_count, :id, default: 0 do |ids|
    p "try loading :comment_count with #{ids.inspect}"
    CommentRepositoy.instance.load.each_with_object(Hash.new(0)) {|e, a| a[e.post_id] += 1  }
  end

  bulk_loader :comment_user_count, :id, default: 0 do |ids|
    p "try loading :comment_user_count with #{ids.inspect}"
    CommentRepositoy.instance.load
                    .each_with_object({}) {|e, a| a[e.post_id] ||= Set.new; a[e.post_id].add(e.user_id) }
                    .each_with_object({}){ |(key, user_ids), a| a[key] = user_ids.size }
  end

  bulk_loader :comment_exist?, :id, default: false do |ids|
    p "try loading :comment_exist? with #{ids.inspect}"
    CommentRepositoy.instance.load.each_with_object({}) {|e, a| a[e.post_id] = true }
  end

  bulk_loader :commented?, :id, default: false do |ids, current_user|
    CommentRepositoy.instance.load.each_with_object({}) {|e, a| a[e.post_id] = true if e.user_id == current_user&.id }
  end

  def initialize(id:)
    self.id = id
  end
end

class User
  attr_accessor :id
  def initialize(id:)
    self.id = id
  end
end

repository = CommentRepositoy.instance
post1 = Post.new(id: 1)
post2 = Post.new(id: 2)
post3 = Post.new(id: 3)

repository.push(Comment.new(id: 1, user_id: 1, post_id: post1.id))
repository.push(Comment.new(id: 2, user_id: 1, post_id: post1.id))
repository.push(Comment.new(id: 3, user_id: 2, post_id: post1.id))
repository.push(Comment.new(id: 4, user_id: 1, post_id: post2.id))
repository.push(Comment.new(id: 5, user_id: 2, post_id: post2.id))

Post.bulk_loader.load([:comment_count, :comment_user_count, :comment_exist?], [post1, post2, post3, post1])
# p post1.bulk_loader.comment_count
p post1.comment_count
p post2.comment_count
p post1.comment_exist?
p post3.comment_exist?
p post1.comment_user_count

current_user = User.new(id: 1)
Post.bulk_loader.load(:commented?, [post1, post2, post3], nil)
p post1.commented?
