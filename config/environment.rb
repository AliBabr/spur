# Load the Rails application.
require_relative 'application'



config.action_mailer.raise_delivery_errors = true
config.action_mailer.perform_caching = false
# config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
config.action_mailer.default_url_options = { host: 'https://spur10.herokuapp.com' }
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address:              'smtp.gmail.com',
  port:                 25,
  domain:               'gmail.com',
  user_name:            'spur10.system@gmail.com',
  password:             'spur12345678',
  authentication:       'plain'
  # enable_starttls_auto: true
  # ^ ^ remove this option ^ ^
}


# Initialize the Rails application.
Rails.application.initialize!
