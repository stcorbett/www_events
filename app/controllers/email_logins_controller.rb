class EmailLoginsController < ApplicationController
  skip_before_action :require_login

  SIGNED_ID_PURPOSE = :email_login
  TOKEN_LIFETIME    = 1.hour

  # GET /login/email
  def new
  end

  # POST /login/email
  # Two submit buttons share this action — params[:commit] tells them apart.
  def create
    @email = params[:email].to_s.downcase.strip
    creating = params[:commit] == "Create Account"

    if @email.blank?
      @error = "Please enter your email address."
      render :new, status: :unprocessable_entity
      return
    end

    user = User.find_by("LOWER(email) = ?", @email)

    if creating
      if user
        @error = "An account already exists for #{@email}. Use \"Send Login Email\" to sign in."
        render :new, status: :unprocessable_entity
      else
        user = User.create!(
          email:    @email,
          provider: 'email',
          uid:      @email,
          name:     @email.split('@').first
        )
        deliver_login_link(user)
        redirect_to email_login_sent_path
      end
    else
      if user
        deliver_login_link(user)
        redirect_to email_login_sent_path
      else
        @error = "We couldn't find an account for #{@email}. Click \"Create Account\" to make a new one."
        render :new, status: :unprocessable_entity
      end
    end
  end

  # GET /login/email/sent
  def sent
  end

  # GET /login/email/:token
  def authenticate
    user = User.find_signed(params[:token], purpose: SIGNED_ID_PURPOSE)
    if user
      session[:user_id] = user.id
      destination = session.delete(:return_to_url) || root_path
      redirect_to destination, notice: "Signed in as #{user.email}"
    else
      redirect_to email_login_path, alert: "That sign-in link is invalid or has expired. Try sending a new one."
    end
  end

  private

  def deliver_login_link(user)
    token = user.signed_id(purpose: SIGNED_ID_PURPOSE, expires_in: TOKEN_LIFETIME)
    UserMailer.login_link(user, token).deliver_now
  end
end
