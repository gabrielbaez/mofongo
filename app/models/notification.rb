class Notification < ApplicationRecord
  belongs_to :recipient, class_name: 'User'
  belongs_to :actor, class_name: 'User', optional: true
  belongs_to :notifiable, polymorphic: true
  
  scope :unread, -> { where(read_at: nil) }
  scope :recent, -> { order(created_at: :desc).limit(10) }
  
  after_create_commit :broadcast_to_recipient
  
  def self.notify(recipient:, actor: nil, action:, notifiable:)
    create(
      recipient: recipient,
      actor: actor,
      action: action,
      notifiable: notifiable
    )
  end
  
  def mark_as_read!
    update!(read_at: Time.current)
  end
  
  private
  
  def broadcast_to_recipient
    broadcast_prepend_later_to(
      recipient,
      :notifications,
      target: 'notifications-list',
      partial: 'notifications/notification',
      locals: { notification: self }
    )
    
    broadcast_update_later_to(
      recipient,
      :notifications_badge,
      target: 'notifications-badge',
      partial: 'notifications/badge',
      locals: { user: recipient }
    )
  end
end
