# /fix-docs

## Description
Intelligently review and update repository documentation by analyzing recent code changes, identifying documentation locations and generation methods, and using multiple specialized sub-agents to ensure documentation accuracy, consistency, and completeness.

## Process

### Phase 1: Documentation Discovery

1. **Locate Documentation**
   - Search for common documentation locations:
     - `docs/` directory
     - `documentation/` directory
     - `README.md` and other root-level markdown files
     - `*.rst` files (reStructuredText for Sphinx)
     - `wiki/` directory
     - API documentation directories
     - `examples/` or `tutorials/` directories
   - Identify documentation structure and organization

2. **Identify Documentation System**
   - Check for documentation generation tools:
     - Sphinx (conf.py, Makefile with sphinx-build)
     - MkDocs (mkdocs.yml)
     - Docusaurus (docusaurus.config.js)
     - Jekyll (_config.yml)
     - Plain markdown/text files
   - Look for build commands in Makefile or package.json
   - Identify any auto-generation from docstrings (autodoc, etc.)

3. **Understand Documentation Scope**
   - API documentation vs. user guides
   - Code examples and tutorials
   - Configuration documentation
   - Architecture documentation
   - Installation and setup guides

### Phase 2: Change Analysis

1. **Review Recent Changes**
   - Run `git log -p --since="3 months ago"` to see recent code changes
   - Focus on:
     - Public API changes (function signatures, class interfaces)
     - Renamed or moved modules
     - Deprecated functionality
     - New features or capabilities
     - Changed configuration options
     - Modified examples or workflows

2. **Identify Documentation Impact**
   - Map code changes to documentation sections
   - Find references to changed functions/classes in docs
   - Identify missing documentation for new features
   - Spot outdated examples or code snippets

### Phase 3: Multi-Agent Review

Launch multiple specialized sub-agents in parallel, each with a specific review perspective:

1. **Technical Accuracy Reviewer**
   - Verify function signatures match documentation
   - Check that code examples actually work
   - Ensure technical details are correct
   - Validate configuration options and parameters

2. **Grammar and Style Reviewer**
   - Check for grammatical errors
   - Ensure consistent writing style
   - Verify proper technical terminology usage
   - Check for clarity and readability

3. **Consistency Reviewer**
   - Ensure consistent formatting across all docs
   - Verify naming conventions are followed
   - Check cross-references are valid
   - Ensure consistent use of examples

4. **Code Example Reviewer**
   - Test that code examples are runnable
   - Verify imports are correct
   - Check that examples follow best practices
   - Ensure examples match current API

5. **Completeness Reviewer**
   - Identify undocumented public functions/classes
   - Check for missing error handling documentation
   - Verify all parameters are documented
   - Ensure return values are described

6. **Flow and Structure Reviewer**
   - Evaluate documentation navigation and organization
   - Check that concepts are introduced in logical order
   - Verify links and cross-references work
   - Assess overall documentation coherence

### Phase 4: Synthesis and Recommendations

1. **Aggregate Findings**
   - Collect all sub-agent reports
   - Identify overlapping concerns
   - Prioritize issues by severity:
     - Critical: Broken examples, wrong function signatures
     - High: Missing documentation for public APIs
     - Medium: Outdated examples, inconsistencies
     - Low: Grammar, style improvements

2. **Generate Edit Proposals**
   Organize proposed changes by category:
   
   **API Updates**
   - "Function `calculate_total()` now requires a `tax_rate` parameter - update all examples"
   - "Class `DataProcessor` has been renamed to `DataPipeline` - update all references"
   
   **Code Example Fixes**
   - "Import statements need updating from `old_module` to `new_module`"
   - "Example uses deprecated `process()` method, should use `execute()`"
   
   **New Feature Documentation**
   - "Add documentation for new `async_process()` method"
   - "Document new configuration options for caching"
   
   **Architectural Changes**
   - "Remove references to deprecated microservice architecture"
   - "Update workflow diagrams to reflect new pipeline structure"
   
   **Consistency Fixes**
   - "Standardize parameter documentation format"
   - "Unify code example styling"

3. **Present Recommendations**
   - Provide a summary of findings
   - Group changes by file/section
   - Include rationale for each change
   - Offer specific edit suggestions with before/after examples

### Phase 5: User Review and Implementation

1. **Present Changes for Approval**
   - Show proposed edits organized by priority
   - Provide context from recent code changes
   - Allow user to approve/reject individual changes

2. **Apply Approved Changes**
   - Make approved edits to documentation files
   - Preserve documentation formatting conventions
   - Maintain any special markup or directives

3. **Build Documentation (if applicable)**
   - Run documentation build command if identified
   - Report any build errors
   - Suggest fixes for build issues

## Important Considerations

- **No Assumptions**: Don't assume documentation structure - discover it
- **Preserve Style**: Maintain existing documentation voice and style
- **Test Examples**: Ensure code examples are actually runnable
- **Version Awareness**: Consider if docs are versioned
- **External Dependencies**: Check if examples rely on external services
- **Professional Tone**: No emojis or casual language in documentation
- **Incremental Updates**: Focus on updating existing docs rather than rewriting

## Output Format

The command will produce a structured report:

```
Documentation Review Report
==========================

Documentation System: [Sphinx/MkDocs/Markdown/etc.]
Location: [docs/ or other]
Build Command: [make docs or similar]

Critical Issues (Fix immediately):
- [Issue description and proposed fix]

High Priority Updates:
- [Function signature changes]
- [Missing documentation]

Medium Priority Improvements:
- [Outdated examples]
- [Inconsistencies]

Low Priority Enhancements:
- [Style improvements]
- [Grammar fixes]

Proposed Edits:
[Detailed edit suggestions with file paths and line numbers]
```

## Error Handling

- If no documentation found: Report to user and offer to create basic README
- If build system unclear: Present findings and ask for clarification
- If changes too extensive: Prioritize and handle in batches
- If sub-agents disagree: Present both perspectives for user decision