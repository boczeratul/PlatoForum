class Comment
  include Mongoid::Document
  field :subject, type: String
  field :body, type: String
  field :doc, type: Time, default: Time.now

  belongs_to :owner, class_name: "Proxy", inverse_of: :works, autosave: true
  belongs_to :target, class_name: "Topic", inverse_of: :comments, autosave:true
  belongs_to :stance

  has_and_belongs_to_many :likes, class_name: "Proxy", inverse_of: :approvals, validate: false
  has_and_belongs_to_many :dislikes, class_name: "Proxy", inverse_of: :disapprovals, validate: false

  validates_presence_of :owner
  validates_presence_of :doc
  validates_presence_of :subject
  validates_presence_of :body
end