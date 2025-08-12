## Principles

- Never be sycophantic, give straightforward honest feedback with the intention of correcting errors and improving results
- Never use emoji in error messages, logs, documentation, comments or READMEs. Your tone should be professional or maybe a bit snarky but not stuffed with emojis and bullet points. For documentation, aim for something interesting to read but still clearly expressing the point.

## Writing Python Tests (PyTest)

We use PyTest for all Python testing. Run tests with `make test` unless otherwise specified.

### Core Testing Principles

- **Single Responsibility**: Each test should focus on testing one concept or behavior at a time. Don't chain multiple concerns together.
- **Fast and Reliable**: Tests must be fast and deterministic — no flaky tests. They should always pass or fail reliably.
- **Independent**: Tests must run in any order or in parallel. Never rely on other tests running first.
- **No External Dependencies**: Unit tests should test inputs and outputs of functions without requiring remote API calls or database setup — those belong in functional/integration tests.

### Test Naming Convention

Use the pattern: `<method_under_test>_<condition_being_tested>_<expected_result>`

Examples:
- `test_calculate_total_when_empty_cart_returns_zero`
- `test_validate_email_with_invalid_format_raises_validation_error`
- `test_process_payment_when_insufficient_funds_returns_declined_status`

### Guidelines

- Never comment out failing tests — fix them or ask for help.
- Prefer real inputs and outputs over mocks when possible.
- Good code design should make tests easy to write without excessive mocking.
- Tests should be readable narratives that clearly express what's being tested.

### Test Structure

Tests should follow a clear narrative pattern:

```python
def test_fetch_user_when_user_exists_returns_user_data():
    # Given: setup context
    user_id = 123
    
    # When: perform action
    result = fetch_user(user_id)
    
    # Then: assert outcome
    assert result.id == 123
    assert result.name == "Expected Name"
```

## Python Language Server Tools (MCP cclsp)

When working with Python code, always prefer using the MCP cclsp language server tools over basic text manipulation. These tools provide intelligent code understanding and refactoring capabilities.

### Available Tools

#### 1. Finding Definitions (`mcp__cclsp__find_definition`)
Use this to locate where a symbol (function, class, variable, method) is defined.
- **When to use**: Before modifying a function/class to understand its definition
- **Parameters**: file_path, symbol_name, symbol_kind (optional)
- **Example use case**: Finding where a function is implemented before refactoring

#### 2. Finding References (`mcp__cclsp__find_references`)
Use this to find all places where a symbol is used throughout the codebase.
- **When to use**: Before renaming or modifying a function/class to understand its usage
- **Parameters**: file_path, symbol_name, symbol_kind (optional), include_declaration
- **Example use case**: Checking all callers of a function before changing its signature

#### 3. Renaming Symbols (`mcp__cclsp__rename_symbol`)
Use this for safe, project-wide renaming of functions, classes, variables, or methods.
- **When to use**: Instead of find-and-replace when renaming Python symbols
- **Parameters**: file_path, symbol_name, new_name, symbol_kind (optional)
- **Note**: If multiple symbols match, use `rename_symbol_strict` with specific position

#### 4. Strict Renaming (`mcp__cclsp__rename_symbol_strict`)
Use this when rename_symbol returns multiple candidates and you need to target a specific instance.
- **When to use**: For precise renaming at a specific code location
- **Parameters**: file_path, line, character, new_name
- **Example use case**: Renaming a local variable that shares a name with other symbols

#### 5. Getting Diagnostics (`mcp__cclsp__get_diagnostics`)
Use this to get language-level errors, warnings, and hints for a file.
- **When to use**: After making changes to verify code correctness
- **Parameters**: file_path
- **Example use case**: Checking for syntax errors or type issues after refactoring

#### 6. Restarting Servers (`mcp__cclsp__restart_server`)
Use this if the language server becomes unresponsive or needs refreshing.
- **When to use**: If language server tools stop working correctly
- **Parameters**: extensions (optional array, e.g., ["py"])
- **Example use case**: Refreshing after installing new dependencies

### Best Practices

1. **Before Refactoring**: Always use `find_references` to understand impact
2. **For Renaming**: Prefer `rename_symbol` over manual find-and-replace
3. **After Changes**: Run `get_diagnostics` to catch syntax/type errors early
4. **Symbol Types**: Common symbol_kind values include "function", "class", "variable", "method"
5. **Workflow Order**:
   - First: `find_definition` to understand the code
   - Second: `find_references` to assess impact
   - Third: Make changes using `rename_symbol` or manual edits
   - Fourth: `get_diagnostics` to verify correctness

### Example Workflow

When asked to refactor a function:
1. Use `find_definition` to locate the function implementation
2. Use `find_references` to find all callers
3. Make necessary changes (using `rename_symbol` if renaming)
4. Use `get_diagnostics` on modified files to ensure no errors
5. Run tests to verify behavior hasn't changed