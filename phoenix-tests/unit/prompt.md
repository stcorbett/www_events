Analyze the following code from a Rails application, which includes this file to test.

File to test:
```
{code}
```
Context:
```
{context}
```

Your task is to:
1. **Identify All Code Paths**: Parse the provided code, find all the code paths, and identify the possible inputs and outputs for each path.
2. **Generate Tests for Code Path**: Write complete unit tests for all code paths, including edge cases and error conditions. Ensure that each test covers a specific code path and provides the necessary input to trigger that path. Mock out outside libraries.
3. **Generate Full Unit Test Suite**: Write a complete test suite that covers:
4. **Tests should not create database tables or define factories**: The tests should assume tables and factories have already been created and are provided in the included context.
5. **Tests should be best practices**: Tests should always follow best practices for Rails and Rspec testing

The final output should be Ruby code that contains:
- **Dynamic Tests for All code paths**: Write RSpec tests for each code path associated with the file, ensuring the use of dynamic selectors (avoid hardcoding element IDs).
- **Modular Structure**: Organize the tests into reusable and modular blocks, using RSpec `beforeEach` hooks to set up reusable functionality (like logging in) and reduce code repetition.
- **Test Independence**: Ensure that each test is independent and does not rely on the state of other tests. Each test case should create its own data in a `before` hook.
- **Error Handling and Assertions**: Include detailed assertions for successful interactions, handling error conditions where applicable.
- **Assure proper namespacing**: Make sure classes are properly namespaced to prevent errors.

Style choices:
- Prefer spec_helper to rails_helper
- Do not test private methods directly, test them through the public methods that call them

The final output should be a complete Ruby file containing all RSpec tests for the files and its associated codepaths, ready to be executed within an RSpec test suite.

Output code only with no explanations, just sweet sweet code.
