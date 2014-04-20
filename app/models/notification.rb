require 'net/http'

class Notification
  include Mongoid::Document
  
  field :noti_type, type: Symbol
  # :NewComment, :NewSupport, :NewOppose, :NewLike, :NewDislike, :Other

  field :source_id, type: String
  field :destination_id, type: String
  field :doc, type: Time, default: Time.zone.now
  #field :stance, type: Integer

  field :read, type: Boolean, default: false

  belongs_to :target, class_name: "User", inverse_of: :notifications, autosave: true

  #before_save :push_notification

  def push_notification
    if self.target.level == 10
      GRAPH_API.put_connections(self.target.uid, "notifications", template: self.display_message, href: "/notification/#{self.id}")
    end
  end

  def display_message
    case self.noti_type
      when :NewComment
        comment = Comment.find(self.source_id) 
        return "#{comment.owner.display_name} 在 #{comment.topic.name} 中發佈了一則新評論 #{comment.display_abstract}" 
      when :NewSupport
        comment = Comment.find(self.source_id) 
        target = Comment.find(self.destination_id) 
        return "#{comment.owner.display_name} 支援了你在 #{comment.topic.name} 上的評論 #{target.display_abstract}" 
      when :NewOppose 
        comment = Comment.find(self.source_id) 
        target = Comment.find(self.destination_id) 
        return "#{comment.owner.display_name} 反駁了你在 #{comment.topic.name} 上的評論 #{target.display_abstract}" 
      when :NewLike 
        someone = Proxy.find_by(:id => self.source_id) 
        target = Comment.find(self.destination_id) 
        return "#{someone.display_name} 覺得你在 #{target.topic.name} 上的評論 #{target.display_abstract} 很讚！" 
      when :NewDislike 
        someone = Proxy.find_by(:id => self.source_id) 
        target = Comment.find(self.destination_id) 
        return "#{someone.display_name} 覺得你在 #{target.topic.name} 上的評論 #{target.display_abstract} 很爛！"
      when :Other
        return self.source_id
      when :Announcement
        return self.source_id
    end
  end
end
