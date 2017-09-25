class UsersController < ApplicationController
  before_filter :skip_first_page, only: :new
  # before_filter :handle_ip, only: :create

  require 'sendgrid-ruby'
  include SendGrid

  def new
    @bodyId = 'home'
    @is_mobile = mobile_device?

    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def create
    ref_code = cookies[:h_ref]
 #   email = params[:user][:email]
    @user = User.new(user_params)
    @user.referrer = User.find_by_referral_code(ref_code) if ref_code

    if @user.save
      cookies[:h_email] = { value: @user.email }
      UserMailer.signup_email(@user).deliver

      # from = Email.new(email: ENV["GMAIL_USERNAME"])
      # to = Email.new(email: @user.email)
      # subject = 'Thanks for signing up!'
      # content = Content.new(type: 'text/plain', value: 'and easy to do anywhere, even with Ruby')
      # mail = Mail.new(from, subject, to, content)

      # sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
      # response = sg.client.mail._('send').post(request_body: mail.to_json)
      # puts response.status_code
      # puts response.body
      # puts response.headers

      redirect_to '/refer-a-friend'
    else
      logger.info("Error saving user with email, #{email}")
      redirect_to root_path, alert: 'Something went wrong!'
    end
  end

  def user_params
    params.require(:user).permit(:email)
  end

  def refer
    @bodyId = 'refer'
    @is_mobile = mobile_device?

    @user = User.find_by_email(cookies[:h_email])

    respond_to do |format|
      if @user.nil?
        format.html { redirect_to root_path, alert: 'Something went wrong!' }
      else
        format.html # refer.html.erb
      end
    end
  end

  def policy
  end

  def redirect
    redirect_to root_path, status: 404
  end

  private

  def skip_first_page
    return if Rails.application.config.ended

    email = cookies[:h_email]
    if email && User.find_by_email(email)
      redirect_to '/refer-a-friend'
    else
      cookies.delete :h_email
    end
  end

  # def handle_ip
  #   # Prevent someone from gaming the site by referring themselves.
  #   # Presumably, users are doing this from the same device so block
  #   # their ip after their ip appears three times in the database.

  #   address = request.env['HTTP_X_FORWARDED_FOR']
  #   return if address.nil?

  #   current_ip = IpAddress.find_by_address(address)
  #   if current_ip.nil?
  #     current_ip = IpAddress.create(address: address, count: 1)
  #   elsif current_ip.count > 2
  #     logger.info('IP address has already appeared three times in our records.
  #                Redirecting user back to landing page.')
  #     return redirect_to root_path
  #   else
  #     current_ip.count += 1
  #     current_ip.save
  #   end
  # end
end
