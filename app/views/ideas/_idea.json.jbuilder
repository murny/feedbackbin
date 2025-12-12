# frozen_string_literal: true

json.extract! idea, :id, :title, :body, :created_at, :updated_at
json.url idea_url(idea, format: :json)
json.body idea.body.to_s
