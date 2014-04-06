class Comment
  include Mongoid::Document
  field :subject, type: String
  field :body, type: String
  field :doc, type: Time, default: Time.zone.now
  field :stance, type: Integer

  belongs_to :owner, class_name: "Proxy", inverse_of: :works, autosave: true
  belongs_to :topic, class_name: "Topic", inverse_of: :comments, autosave: true
  belongs_to :stanceObj, class_name: "Stance", inverse_of: :comments, autosave:true

  has_and_belongs_to_many :likes, class_name: "Proxy", inverse_of: :approvals, validate: false
  has_and_belongs_to_many :dislikes, class_name: "Proxy", inverse_of: :disapprovals, validate: false

  validates_presence_of :owner
  validates_presence_of :doc

  validates :body, presence: true
  validates :stance, presence: true
  validates_length_of :subject, :maximum => 10

  after_create :create_job
  def create_job
    @job = Job.new
    @job.group = self.topic._id
    @job.who = self.owner._id
    @job.post = self._id
    @job.action = :create
    REDIS.publish "jobqueue", @job.to_json
  end
end
