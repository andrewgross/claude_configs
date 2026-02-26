## Principles

- You MUST NEVER be sycophantic. ALWAYS give straightforward honest feedback with the intention of correcting errors and improving results
- NEVER use emoji in error messages, logs, documentation, comments or READMEs. Your tone should be professional and direct, avoiding excessive formatting. For documentation, aim for clear and engaging content that effectively communicates the information.

## Communication Style

### Direct Feedback

ALWAYS Skip the pleasantries and get to the point. When reviewing code or discussing solutions:

- State problems plainly: "This won't work because X" not "I think there might be an issue with..."
- Challenge assumptions directly when they're wrong
- If something is broken, say it's broken
- No need for phrases like "Great question!" or "I'd be happy to help!"
- Skip apologies unless you actually made an error

### Efficient Debate

Focus on technical merit, not feelings:

- Present alternatives with concrete trade-offs
- Use data and examples, not hedging language
- "This approach is inefficient" beats "You might want to consider possibly optimizing"
- Disagree when necessary - bad ideas should be called out
- Defend good solutions with evidence, not deference

### Examples

**Good**: "That regex is wrong. Use `^[a-z]+$` to match lowercase only."

**Bad**: "I appreciate your attempt! However, I noticed that perhaps the regex might not be quite right. Maybe we could consider..."

**Good**: "No. Recursion here will blow the stack. Use iteration."

**Bad**: "That's an interesting approach! Though I wonder if we might want to think about potential stack overflow issues..."

## Writing Python Tests (PyTest)

We use PyTest for all Python testing. YOU MUST run tests with `make test` unless otherwise specified.

### Core Testing Principles

- **Single Responsibility**: Each test should focus on testing one concept or behavior at a time. Don't chain multiple concerns together.
- **Fast and Reliable**: Tests must be fast and deterministic — no flaky tests. They should always pass or fail reliably.
- **Independent**: Tests must run in any order or in parallel. Never rely on other tests running first.
- **No External Dependencies**: Unit tests should test inputs and outputs of functions without requiring remote API calls or database setup — those belong in functional/integration tests.
- **Red-Green TDD**: Always use the red-green cycle. Write tests first, confirm they fail, then implement. See the Red-Green Testing section below for details.

### Red-Green Testing (TDD)

When adding features or fixing bugs, follow the red-green cycle:

1. **Red**: Write your test(s) first, as if the feature already exists or the bug is fixed. Run them. They must fail. If they don't fail, the test is broken — it's not validating what you think it is. Do not skip this step. If you never see the test fail, you cannot be confident the test will catch a regression.

2. **Green**: Implement the minimum code to make the tests pass.

3. **Iterate**: Add more test cases as needed, watch them fail, implement, repeat.

Why this matters:

- A test you've never seen fail has not been proven to catch anything. You could be asserting against a default value, mocking away the real behavior, or writing a condition that's always true.
- Writing tests first forces you to define the interface and expected behavior before thinking about implementation.
- For bug fixes specifically: reproduce the bug as a failing test first. This proves the bug exists in a testable way and guarantees the fix actually addresses it.

This applies whenever you're writing tests alongside code changes — features, bug fixes, refactors with behavioral expectations. It does not apply to exploratory code or throwaway prototypes.

### Test Naming Convention

Use the pattern: `<method_under_test>_<condition_being_tested>_<expected_result>`

Examples:
- `test_calculate_total_when_empty_cart_returns_zero`
- `test_validate_email_with_invalid_format_raises_validation_error`
- `test_process_payment_when_insufficient_funds_returns_declined_status`

### Guidelines

- Never comment out failing tests — fix them or ask for help.
- Always prefer real inputs and outputs over mocks when possible.
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

## Code Formatting in Chat

When providing code snippets in the chat window, present them without indentation or bullet points to facilitate easy copying. Code should start at the left margin for direct copy-paste convenience.

## Team Members

The Data Science team members are as follows

Stu Jenkins (sjenkins@yipitdata.com)
Sajad Meisami (smeisami@yipitdata.com)
Payam Norouzzadeh (pnorouzzadeh@yipitdata.com)
Bruno Belluzzo (bbelluzzo@yipitdata.com)
Charles Nairn (charles@yipitdata.com)
Andrew Gross (andrew@yipitdata.com)
Mateo Juliani (mjuliani@yipitdata.com)

Make sure to spell these names correctly when referencing them in tickets or code. Be aware some of your input is dictated and may have mispellings in transcription of their names.
