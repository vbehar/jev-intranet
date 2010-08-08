require 'mongo_mapper'
require 'state_machine'

# Represents a yearly subscription from a member to the association
class Subscription
  include MongoMapper::Document

  many :states, :class_name => 'WorkflowAction'

  key :user_id,    String,  :required => true
  key :deleted,    Boolean, :default  => false
  timestamps!

  # workflow
  state_machine :state, :initial => :new do
    state :new
    state :waiting_payment
    state :paid

    event :accept do
      transition :new => :waiting_payment
    end
    event :pay do
      transition [:new, :waiting_payment] => :paid
    end
  end

  def initialize
    # override events to save workflow actions
    %w(accept pay).each do |method|
      (class << self; self; end).class_eval do
        define_method method do |user_id, *args|
          previous_state = state
          super
          states << WorkflowAction.new(:user_id => user_id, :event => method, :previous_state => previous_state, :new_state => state) if state != previous_state
        end
      end
    end

    # required by state_machine
    super()
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

