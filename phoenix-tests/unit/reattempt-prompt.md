You have the following information:

1. **Test Failures**: Information about failed tests is provided below. This includes error messages and logs for the tests that failed. Test errors may include hints to how to resolve the error itself:

```
{test_errors}
```

2. **Test File and Context**: The current test file and additional context about the application is provided below:

Test File:
```
{test_file}
```

Code:
```
{code}
```

Context:
```
{context}
```

Your task is to:

1. **Analyze the Test Failures**: Review the failure information and error logs provided. Identify the root cause of the test failures, such as incorrect namespacing, missing assertions, missing functions or factories.
2. **Modify the Tests to Fix the Failures**: Based on the failure details, update the tests to fix the issues. Ensure the tests now handle UI interactions correctly, such as handling hover events, confirmation dialogs, and dynamic elements.
3. **Ensure All Tests Pass**: The final output should be a complete Ruby file containing all tests for all codepaths in the file. This includes both the tests that passed initially and the tests that you have fixed.
4. **Tests should not create database tables**: The tests should assume tables have already been created and are provided in the included schema file.
5. **Tests should be best practices**: Tests should always follow best practices for Rails and Rspec testing

Your final output should:

- Include **all the tests**, with fixes applied to the failing tests.
- Maintain the structure and best practices of the original tests (such as dynamic selectors, reusable test blocks, and proper handling of UI elements like hover or confirmation dialogs).
- Ensure tests are modular and can be reused in the future.
- Retain all assertions from both the passing and fixed tests to verify that the application behaves correctly.

The final output should be a complete Ruby file containing the fixed test suite for the, ready to be copied and executed.

Output code only with no explanations, any non code that slips by should be commented out.
