class UserMailer < ApplicationMailer
  # Sends a one-click sign-in link to the user. `token` is a Rails signed_id
  # so the controller can verify it on click without storing anything in the DB.
  def login_link(user, token)
    @user = user
    @url  = email_login_authenticate_url(token)
    mail(to: user.email, subject: "Your WhatWhereWhen sign-in link")
  end
end
