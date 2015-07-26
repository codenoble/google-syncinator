class DeprovisionSchedule
  include Mongoid::Document
  include Mongoid::Timestamps

  ACTIONS = [:notify_of_inactivity, :notify_of_closure, :suspend, :delete, :activate]
  STATE_MAP = {
    activate: :active,
    suspend: :suspended,
    delete: :deleted
  }

  embedded_in :university_email

  field :action, type: Symbol
  field :reason, type: String
  field :scheduled_for, type: DateTime
  field :completed_at, type: DateTime
  field :canceled, type: Boolean
  field :job_id, type: String

  validates :action, presence: true
  validates :scheduled_for, presence: true, unless: :completed_at?
  validates :completed_at, presence: true, unless: :scheduled_for?
  validates :action, inclusion: {in: ACTIONS}

  def pending?
    !(completed_at? || canceled?)
  end

  after_save do
    if completed_at_changed? && completed_at.present?
      university_email.update state: STATE_MAP[action]
    end
  end
end
