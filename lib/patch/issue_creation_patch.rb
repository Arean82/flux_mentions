module Patch
  module IssueCreationPatch
    def self.included(base)
      base.class_eval do
        after_create :send_mail_on_create
        
        def send_mail_on_create
          issue = self
          project = self.project
          return unless project

          users = project.users.to_a.delete_if { |u| (u.type != 'User' || u.mail.blank?) }
          settings = Setting.plugin_flux_mentions || {}
          mention_symbol = settings['symbol'].presence || '@'
          
          # Scan description for mentions
          if issue.description.present?
            escaped_sym = Regexp.escape(mention_symbol)
            mentioned_users = users.select do |u|
              pattern = /(?:^|\s)#{escaped_sym}#{Regexp.escape(u.login)}(?=[^\w]|$)/
              issue.description =~ pattern
            end

            mentioned_users.each do |mentioned_user|
              if ActionMailer::Base.smtp_settings[:address].present?
                begin
                  IssueMailer.new_issue_description(issue, nil, mentioned_user).deliver_now
                rescue Net::SMTPAuthenticationError => e
                  Rails.logger.error "SMTP Error: #{e.message}"
                rescue => e
                  Rails.logger.error "Mention Mailer Error: #{e.message}"
                end
              else
                Rails.logger.info "SMTP settings not configured. Email not sent."
              end
            end
          end
        end
      end
    end
  end
end
