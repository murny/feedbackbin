# FeedbackbinElements Test Suite

## TODO: Set Up Dummy Rails App for Testing

This directory is prepared for engine tests but requires a dummy Rails application to run properly.

### Setup Steps (Future Work)

1. **Generate Dummy App**
   ```bash
   cd lib/feedbackbin_elements
   rails plugin new . --dummy-path=test/dummy --skip-test
   ```

2. **Configure Dummy App**
   - Mount the engine in `test/dummy/config/routes.rb`:
     ```ruby
     Rails.application.routes.draw do
       mount FeedbackbinElements::Engine, at: "/"
     end
     ```

3. **Update test_helper.rb**
   - Load the dummy app environment
   - Configure test fixtures
   - Set up any necessary test helpers

4. **Run Tests**
   ```bash
   cd lib/feedbackbin_elements
   bin/rails test
   ```

### Current Test Files

- `controllers/feedbackbin_elements/docs/components_controller_test.rb` - Tests for component documentation pages

All tests are currently skipped until the dummy app is set up.

### Alternative: Integration Testing

Until the dummy app is created, the engine can be tested through the main FeedbackBin application's integration tests, since the helpers are loaded into the main app's views.
