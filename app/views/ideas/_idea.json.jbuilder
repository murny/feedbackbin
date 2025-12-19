# frozen_string_literal: true

json.extract! idea, :id, :title, :created_at, :updated_at
json.url idea_url(idea, format: :json)
json.description idea.description.to_s
