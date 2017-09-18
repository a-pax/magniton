class UserMailer < ActionMailer::Base
  default from: ENV["MAILER_SENDER"]

  def signup_email(user)
    @user = user
    @twitter_message = "#Makeup is evolving! Excited for @Magnitone #blendup to launch."
    mail to: user.email, subject: "Thanks for signing up!"
  end
end

