# Style

We aim to write code that reads well, looks consistent, and makes the intent clear. When writing new code, find similar code elsewhere in the codebase for inspiration.

## Conditional returns

In general, we prefer to use expanded conditionals over guard clauses.

```ruby
# Bad
def todos_for_new_idea
  ids = params.require(:idea)[:comment_ids]
  return [] unless ids
  @account.ideas.find(ids.split(","))
end

# Good
def todos_for_new_idea
  if ids = params.require(:idea)[:comment_ids]
    @account.ideas.find(ids.split(","))
  else
    []
  end
end
```

This is because guard clauses can be hard to read, especially when they are nested.

As an exception, we sometimes use guard clauses to return early from a method:

* When the return is right at the beginning of the method.
* When the main method body is not trivial and involves several lines of code.

```ruby
def after_recorded(recording)
  return if recording.parent.was_created?

  if recording.was_created?
    broadcast_new(recording)
  else
    broadcast_change(recording)
  end
end
```

Use postfix `if`/`unless` for simple, single-line statements:

```ruby
before_create :assign_external_account_id, unless: :external_account_id?
```

Use ternaries sparingly, only for short inline expressions:

```ruby
creator.system? ? system_ids : user_ids
```

## Model ordering

We order model declarations in this order:

1. Constants
2. Concerns / includes
3. Attachments (`has_one_attached`, `has_rich_text`)
4. Associations (`belongs_to`, then `has_many` / `has_one`)
5. Enums
6. Validations
7. Normalizers
8. Scopes
9. Callbacks
10. Class methods
11. Public instance methods
12. Private instance methods

## Methods ordering

We order methods in classes in the following order:

1. `class` methods
2. `public` methods with `initialize` at the top.
3. `private` methods

We order private methods vertically based on their invocation order. This helps us understand the flow of the code.

```ruby
class SomeClass
  def process
    validate_input
    transform_data
  end

  private
    def validate_input
      # ...
    end

    def transform_data
      # ...
    end
end
```

## Visibility modifiers

We don't add a newline under visibility modifiers, and we indent the content under them.

```ruby
class SomeClass
  def some_method
    # ...
  end

  private
    def some_private_method
      # ...
    end
end
```

## To bang or not to bang

We only use `!` for methods that have a corresponding counterpart without `!`. We don't use `!` to flag destructive actions — there are plenty of destructive methods in Ruby and Rails that do not end with `!`.

## CRUD controllers

We model web endpoints as CRUD operations on resources. When an action doesn't map cleanly to a standard CRUD verb, we introduce a new resource rather than adding custom actions.

```ruby
# Bad
resources :ideas do
  post :close
  post :reopen
end

# Good
resources :ideas do
  resource :closure
end
```

## Controller conventions

### `before_action` ordering

1. `allow_unauthenticated_access` (at the very top)
2. `before_action :set_*` (resource finders)
3. `before_action :ensure_*` (authorization guards)

```ruby
allow_unauthenticated_access only: %i[index show]
before_action :set_idea, only: %i[show edit update destroy]
before_action :ensure_permission_to_administer_idea, only: %i[edit update destroy]
```

### Authorization

Use inline guards returning `head :forbidden`:

```ruby
def ensure_permission_to_administer_idea
  head :forbidden unless Current.user&.can_administer_idea?(@idea)
end
```

### Resource scoping

Always scope through `Current.account`:

```ruby
@idea = Current.account.ideas.find(params.expect(:id))
```

### Strong parameters

Use `params.expect` instead of `params.require().permit()`:

```ruby
params.expect(idea: [ :title, :description, :board_id ])
```

### Destroy

Use `destroy!` and redirect with `status: :see_other`:

```ruby
@idea.destroy!
redirect_to ideas_path, status: :see_other, notice: t(".successfully_destroyed")
```

## Controller and model interactions

We favor a vanilla Rails approach with thin controllers directly invoking a rich domain model. We don't use services or other artifacts to connect the two.

Invoking plain Active Record operations is fine:

```ruby
class Ideas::CommentsController < ApplicationController
  def create
    @comment = @idea.comments.create!(comment_params)
  end
end
```

For more complex behavior, we prefer clear, intention-revealing model APIs that controllers call directly:

```ruby
class Ideas::ClosuresController < ApplicationController
  def create
    @idea.close
  end
end
```

## Jobs

We write shallow job classes that delegate the logic itself to domain models:

* Use the suffix `_later` to flag methods that enqueue a job.
* Use the suffix `_now` for the synchronous counterpart when both exist.

```ruby
module Notifiable
  extend ActiveSupport::Concern

  included do
    after_create_commit :notify_recipients_later
  end

  def notify_recipients_later
    NotifyRecipientsJob.perform_later(self)
  end

  def notify_recipients
    # actual logic here
  end
end

class NotifyRecipientsJob < ApplicationJob
  def perform(notifiable)
    notifiable.notify_recipients
  end
end
```

## Association defaults

Use lambda defaults tied to `Current` context so callers don't have to pass account or user explicitly:

```ruby
belongs_to :account, default: -> { Current.account }
belongs_to :creator, class_name: "User", default: -> { Current.user }
```

## General

* Double-quoted strings everywhere.
* `frozen_string_literal: true` at the top of every Ruby file.
* Always use I18n — never hardcode user-facing text. Use scoped helpers like `t(".title")`.
* Use safe navigation (`&.`) when `Current.user` or similar may be nil.
* Use `find_each` for bulk operations in jobs and cleanup tasks.
* Memoize with `||=` when appropriate.
