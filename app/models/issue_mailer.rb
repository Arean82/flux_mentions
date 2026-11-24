class IssueMailer < ActionMailer::Base
  layout 'mailer'
  default from: Setting.mail_from

  helper :application
  include ApplicationHelper

  def self.default_url_options
    ::Mailer.default_url_options
  end

  def notes_notification(issue, journal, user)
    @issue = issue
    @user = user
    @journal = journal
    @author_name = journal.try(:user).try(:name) || User.current.name

    mail(
      to: user.mail,
      subject: "[#{@issue.project.name} - #{@issue.tracker.name} ##{@issue.id}] You were mentioned in notes by #{@author_name}"
    )
  end

  def description_notification(issue, journal, user)
    @issue = issue
    @user = user
    @journal = journal
    @author_name = journal.try(:user).try(:name) || User.current.name

    mail(
      to: user.mail,
      subject: "[#{@issue.project.name} - #{@issue.tracker.name} ##{@issue.id}] You were mentioned in description by #{@author_name}"
    )
  end

  def new_issue_description(issue, journal, user)
    @issue = issue
    @user = user
    @journal = journal
    @author_name = issue.try(:author).try(:name) || User.current.name

    mail(
      to: user.mail,
      subject: "[#{@issue.project.name} - #{@issue.tracker.name} ##{@issue.id}] You were mentioned by #{@author_name}"
    )
  end
end
