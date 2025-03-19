# frozen_string_literal: true

credentials = if Rails.env.development?
                # Local development environment
                Aws::Credentials.new(
                  ENV.fetch('AWS_ACCESS_KEY_ID', nil),
                  ENV.fetch('AWS_SECRET_ACCESS_KEY', nil),
                  ENV.fetch('AWS_SESSION_TOKEN', nil)
                )
              elsif Rails.env.production?
                # Production environment using IRSA
                Aws::AssumeRoleWebIdentityCredentials.new(
                  client: Aws::STS::Client.new(region: ENV.fetch('AWS_REGION', nil)),
                  role_arn: ENV.fetch('AWS_ROLE_ARN', nil),
                  web_identity_token_file: ENV.fetch('AWS_WEB_IDENTITY_TOKEN_FILE', nil),
                  role_session_name: 'MessageRelayServiceSession'
                )
              end
Aws.config.update({
                    region: ENV.fetch('AWS_REGION', nil),
                    credentials: credentials
                  })
