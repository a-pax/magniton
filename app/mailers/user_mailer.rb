class UserMailer < ActionMailer::Base
  default from: ENV["MAILER_SENDER"]

  def signup_email(user)
    @user = user
    @twitter_message = "#Shaving is evolving. Excited for @harrys to launch."

    mail to: user.email, subject: "Thanks for signing up!"
  end
end

:from => "address_you_are_sending_from@your_domain.com"
