require 'mongo_mapper'
require 'state_machine'

# Represents a yearly subscription from a member to the association
class Subscription
  include MongoMapper::Document

  scope :current_year, lambda { where(:year => Subscription.current_subscription_year) }

  many :states, :class_name => 'WorkflowAction'
  one :payment, :class_name => 'Payment'

  key :user_id,                   String,  :required => true
  key :year,                      Integer, :required => true
# key :state,                     String   -> auto-defined by state_machine
  key :medical_certificate_type,  String
  key :medical_certificate_date,  Date
  key :comment,                   String
  key :deleted,                   Boolean, :default  => false
  timestamps!

  validates_uniqueness_of :year, :scope => :user_id, :message => 'non-uniq.year-user_id'
  validate :valid_user_id

  # workflow
  state_machine :state, :initial => :new do
    event :pay do
      transition :new => :paid
    end
    event :key_in do
      transition :paid => :upstream
    end
    event :deliver do
      transition :upstream => :sent
    end
  end

  def initialize(*args)
    # override events to save workflow actions
    # need to fix this !
#    %w(pay key_in deliver).each do |method|
#      (class << self; self; end).class_eval do
#        define_method method do |params, *args|
#          previous_state = state
#          success = super # transition to another state
#          states << WorkflowAction.new(:user_id => params[:user_id], :event => method, :previous_state => previous_state, :new_state => state, :comment => params[:comment]) if success && state != previous_state
#          success
#        end
#      end
#    end

    # required by state_machine
    super
  end

  def pay(params, *args)
    previous_state = state
    success = super # transition to another state
    if success
      states << WorkflowAction.new(:user_id => params[:user_id], :event => 'pay', :previous_state => previous_state, :new_state => state, :comment => params[:comment]) if state != previous_state
      self.payment = Payment.new(:type => params[:type], :amount => params[:amount], :comment => params[:comment], :date => params[:date])
    end
    success
  end

  def key_in(params, *args)
    previous_state = state
    success = super # transition to another state
    if success
      states << WorkflowAction.new(:user_id => params[:user_id], :event => 'key_in', :previous_state => previous_state, :new_state => state, :comment => params[:comment]) if state != previous_state
      self.medical_certificate_type = params[:medical_certificate_type]
      self.medical_certificate_date = params[:medical_certificate_date]
      u = self.user
      u.ffck_number = params[:ffck_number] unless params[:ffck_number].blank?
      u.ffck_number_date = params[:date]
      u.ffck_number_year = self.year
      u.medical_certificate_type = self.medical_certificate_type
      u.medical_certificate_date = self.medical_certificate_date
      u.save
    end
    success
  end

  def deliver(params, *args)
    previous_state = state
    success = super # transition to another state
    if success
      states << WorkflowAction.new(:user_id => params[:user_id], :event => 'deliver', :previous_state => previous_state, :new_state => state, :comment => params[:comment]) if state != previous_state
    end
    success
  end

  # return an array with the number of subscriptions by year and state
  def self.count_by_years_and_states
    Subscription.collection.group(%w(year state),{:deleted => false},{:count => 0},'function(doc,prev) {prev.count++;}')\
                           .map{|o| { :year => o['year'].to_i, :state => o['state'], :count => o['count'].to_i } }
  end

  # return the current year used for requesting a new subscription
  def self.current_subscription_year
    today = Date.today
    today.month >= 8 ? today.next_year.year : today.year
  end

  # find or create a subscription with the given parameters
  def self.find_or_create(params)
    Subscription.where(params).first || Subscription.new(params)
  end

  # return true if this subscription has not been saved yet
  def new?
    self.created_at.nil?
  end

  # mark the subscription as deleted, and save it
  def delete!
    self.deleted = true
    save
  end

  # calculate the subscription price
  def price
    user_birth_year = user.birth_date.year rescue nil
    case year
      when 2010; user_birth_year >= 1996 ? 120 : 160 rescue nil
      when 2011; user_birth_year >= 1997 ? 120 : 160 rescue nil
      when 2012; 160
      when 2013; 170
      when 2014; 170
      else nil
    end
  end

  # return true if the subscription is still editable by the user
  def editable_by_user?
    %w(new paid).include?(self.state)
  end

  def user=(user)
    unless user.nil?
      self.user_id = user.user_id
      @user = user
    end
  end

  def user
    return @user unless @user.nil?
    @user = User.find(self.user_id)
  end

  private

  def valid_user_id
    errors.add(:user_id, 'invalid.user_id') unless !user_id.blank? and User.exist?(user_id)
  end

end

