class Topic
  include Mongoid::Document
  field :description, type: String
  field :permalink, type: String

  has_many :comments, class_name: "Comment", inverse_of: :target, autosave: true, validate: false
  has_many :stances
  has_many :proxies

  validates :description, presence: true
  validates :permalink, uniqueness: true, presence: true
end