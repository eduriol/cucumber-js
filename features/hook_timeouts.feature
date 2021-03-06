Feature: Step definition timeouts

  Background:
    Given a file named "features/step_definitions/cucumber_steps.js" with:
      """
      import {defineSupportCode} from 'cucumber'

      defineSupportCode(({Before, Given, setDefaultTimeout}) => {
        setDefaultTimeout(500);

        Before({tags:' @slow-with-increased-timeout', timeout: 1500}, function(scenario, callback) {
          setTimeout(callback, 1000)
        })

        Before({tags: '@slow'}, function(scenario, callback) {
          setTimeout(callback, 1000)
        })

        Given(/^a passing step$/, function() {})
      })
      """

  Scenario: slow hooks timeout
    Given a file named "features/a.feature" with:
      """
      Feature:
        @slow
        Scenario:
          Given a passing step
      """
    When I run cucumber.js
    Then the output contains the text:
      """
      function timed out after 500 milliseconds
      """
    And the exit status should be 1


  Scenario: slow hooks can increase their timeout
    Given a file named "features/a.feature" with:
      """
      Feature:
        @slow-with-increased-timeout
        Scenario:
          Given a passing step
      """
    When I run cucumber.js
    Then the exit status should be 0


  Scenario: changing hooks timeouts does not effect other hooks
    Given a file named "features/a.feature" with:
      """
      Feature:
        @slow
        @slow-with-increased-timeout
        Scenario:
          Given a passing step
      """
    When I run cucumber.js
    Then the output contains the text:
      """
      function timed out after 500 milliseconds
      """
    Then the exit status should be 1
