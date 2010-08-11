require 'mongo_mapper'
require 'state_machine'

# Represents a yearly subscription from a member to the association
class Subscription
  include MongoMapper::Document

  many :states, :class_name => 'WorkflowAction'
  one :payment, :class_name => 'Payment'

  key :user_id,    String,  :required => true
  key :year,       Integer, :required => true
# key :state,      String   -> auto-defined by state_machine
  key :comment,    String
  key :deleted,    Boolean, :default  => false
  timestamps!

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
    %w(pay key_in deliver).each do |method|
      (class << self; self; end).class_eval do
        define_method method do |options, *args|
          previous_state = state
          success = super # transition to another state
          states << WorkflowAction.new(:user_id => options[:user_id], :event => method, :previous_state => previous_state, :new_state => state, :comment => options[:comment]) if success && state != previous_state
          success
        end
      end
    end

    # required by state_machine
    super
  end

  def pay(options, *args)
    success = super
    if success
      self.payment = Payment.new(:type => options[:type], :amount => options[:amount], :comment => options[:comment], :date => options[:date])
    end
    success
  end

  def key_in(options, *args)
    success = super
    if success
      u = self.user
      u.ffck_number = options[:ffck_number] unless options[:ffck_number].blank?
      u.ffck_number_date = u['ffck_number_date'].to_a.push(options[:date].strftime('%Y-%m-%d'))
      u.ffck_number_year = u['ffck_number_year'].to_a.push(self.year.to_s)
      u.save
    end
    success
  end

  # return an array with the number of subscriptions by year and state
  def self.count_by_years_and_states
    Subscription.collection.group(%w(year state),{:deleted => false},{:count => 0},'function(doc,prev) {prev.count++;}')\
                           .map{|o| { :year => o['year'].to_i, :state => o['state'], :count => o['count'].to_i } }
  end

  # mark the subscription as deleted, and save it
  def delete!
    self.deleted = true
    save
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

end

