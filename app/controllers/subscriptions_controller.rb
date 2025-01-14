class SubscriptionsController < ApplicationController
  before_action :set_subscription, only: [:confirm, :unsubscribe]

  def create
    @subscription = Subscription.new(subscription_params)
    @subscription.user = current_user if user_signed_in?

    if verify_recaptcha(model: @subscription) && @subscription.save
      SubscriptionMailer.with(subscription: @subscription).confirmation.deliver_later
      flash[:notice] = "Please check your email to confirm your subscription."
    else
      flash[:alert] = "Error creating subscription: #{@subscription.errors.full_messages.join(", ")}"
    end

    redirect_back(fallback_location: root_path)
  end

  def confirm
    if @subscription&.confirm!
      flash[:notice] = "Your subscription has been confirmed. Thank you!"
    else
      flash[:alert] = "Invalid or expired confirmation link."
    end

    redirect_to root_path
  end

  def unsubscribe
    if @subscription&.update(unsubscribed_at: Time.current)
      flash[:notice] = "You have been unsubscribed successfully."
    else
      flash[:alert] = "Invalid unsubscribe link."
    end

    redirect_to root_path
  end

  private

  def set_subscription
    @subscription = Subscription.find_by(token: params[:token])
  end

  def subscription_params
    params.require(:subscription).permit(:email)
  end
end
