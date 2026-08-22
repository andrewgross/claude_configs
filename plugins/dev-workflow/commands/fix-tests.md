---
description: Run tests, identify failures, and fix them following best practices
thinking: true
---

I need to run the tests, identify any failures, and fix them properly. Let me start by understanding the test setup and then systematically address any issues.

## Step 1: Discover Test Command

First, I'll check the Makefile for the proper test command:
- Look for `make test` or similar targets in the Makefile
- If no Makefile, try `uv run pytest`
- As a fallback, try `python -m pytest` or `pytest`

## Step 2: Run Initial Test Suite

Run the full test suite to identify all failing tests. I'll capture:
- Which tests are failing
- The specific error messages
- Any patterns in the failures

## Step 3: Analyze Failures

Group related test failures together based on:
- Module/file they're testing
- Type of error (import errors, assertion failures, missing mocks, etc.)
- Common root causes

## Step 4: Fix Tests in Parallel

For each failing test or group of related failing tests, I'll launch a sub-agent to fix them. Each sub-agent will be instructed to:

1. **Run only the specific test(s)** they're assigned to fix using:
   - `pytest path/to/test_file.py::TestClass::test_method` for specific tests
   - Or the appropriate make command with test selection if available

2. **Follow testing best practices from CLAUDE.md**:
   - Test naming: `test_<method_under_test>_<condition_being_tested>_<expected_result>`
   - Single responsibility: Each test focuses on one concept
   - **Fast and reliable: Tests must NEVER be flaky - they should pass or fail consistently**
   - **Independent: Tests MUST be able to run in any order**
   - **Parallel-safe: Tests MUST be able to run in parallel without interference**
   - No external dependencies for unit tests
   - Use Given/When/Then structure for clarity

3. **Ensure test isolation**:
   - Tests should not share state between them
   - Each test should set up its own data and clean up after itself
   - No test should depend on another test running first
   - Tests should not write to shared files or databases without proper isolation
   - Use unique identifiers/namespaces when tests must interact with external resources

4. **Avoid these anti-patterns**:
   - Do NOT comment out failing tests
   - Do NOT over-mock to the point where nothing is actually tested
   - Do NOT add sleeps or waits to "fix" timing issues (this creates flaky tests)
   - Do NOT change test assertions just to make them pass without understanding why they failed
   - Do NOT use global state or class-level variables that persist between tests
   - Do NOT rely on test execution order

5. **Fix root causes**:
   - If it's an import error, fix the import
   - If it's a behavior change, understand if the test or code needs updating
   - If it's a missing dependency, identify and document it
   - If mocking is needed, mock only what's necessary (external services, file I/O)
   - If tests fail when run in parallel, fix the isolation issue (don't disable parallelism)

6. **Verify the fix**:
   - Run the specific test again to confirm it passes
   - Run the test multiple times to ensure it's not flaky
   - Run the test in isolation and with other tests to ensure independence
   - Ensure the test actually tests something meaningful
   - Check that related tests still pass

## Step 5: Final Verification

After all sub-agents complete:
1. Run the full test suite again to ensure no regressions
2. **Run tests with pytest-xdist (`pytest -n auto`) to verify parallel execution works**
3. **Run tests with `--random-order` flag if available to verify order independence**
4. Verify all tests pass reliably (run twice to check for flakiness)
5. Report summary of what was fixed

## Step 6: Handle Unfixable Tests

If any tests cannot be fixed after reasonable attempts:
1. Document why the test is failing
2. Identify what would be needed to fix it (missing fixtures, external dependencies, etc.)
3. Revert any experimental changes
4. Report back to the user with a clear summary of the issue

## Important Notes:
- Always preserve test coverage - don't remove tests without understanding their purpose
- Maintain test readability - tests serve as documentation
- If a test seems wrong, understand the original intent before changing it
- Keep test execution fast - avoid unnecessary setup or teardown
- **Tests are the contract** - they define expected behavior and must be reliable

Let me begin by discovering and running your tests.