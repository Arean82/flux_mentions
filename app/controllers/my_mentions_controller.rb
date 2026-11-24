class MyMentionsController < ApplicationController
  before_action :require_login

  include QueriesHelper
  include SortHelper

  def index
    # Redirect to issues list pre-filtered by mentioned_user_id = me
    redirect_to issues_path(set_filter: 1, f: ['status_id', 'mentioned_user_id'], op: { status_id: 'o', mentioned_user_id: '=' }, v: { mentioned_user_id: ['me'] })
  end
end
