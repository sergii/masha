class Project < ActiveRecord::Base
  include Authority::Abilities
  extend FriendlyId

  friendly_id :name, use: :slugged

  belongs_to :owner, :class_name => 'User'

  has_many :time_shifts
  has_many :timed_projects, :through => :time_shift, :class_name => 'Project'

  has_many :memberships, :dependent => :destroy
  has_many :users, :through => :memberships
  has_many :invites

  scope :ordered, -> { order(:name) }
  scope :active, -> { where(active: true) }
  scope :archive, -> { where(active: false) }

  validates :name, :presence => true, :uniqueness => true
  validates :slug, :presence => true, :uniqueness => true

  # active_admin в упор не видит friendly_id-шный slug
  def to_param
    id
  end

  def to_s
    name
  end

  def roles_of_user user
    applied_roles.select { |r| r.user==user }
  end

  def activate
    self.update_attribute(:active, true)
  end

  def archivate
    self.update_attribute(:active, false)
  end
end
