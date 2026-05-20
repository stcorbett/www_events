class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('MAILER_FROM', 'noreply@whatwherewhen.lakesoffire.org')
  layout 'mailer'
end
