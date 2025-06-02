# Conventions

## Code Structure
- **Methods should have 5 or fewer lines of code** almost all of the time
- **Classes should be under 100 lines** whenever possible
- Break large methods into smaller, focused methods with clear responsibilities
- Split large classes into multiple smaller classes using composition
- Use manager classes and helper classes to distribute responsibility

## Types
- Only allow types to be nullable when *absolutely* required.

## Code Formatting
- **ALWAYS** run Crystal formatter before saving Crystal code: `crystal tool format src/ spec/`
- Crystal formatter must be run on all `.cr` files to ensure consistent code style
- This is enforced in CI and will cause builds to fail if not followed

### Line Length and Formatting Rules
- **Maximum line length: 120 characters** for all Crystal and TypeScript files
- When breaking long lines into multiple lines:
  - Each parameter/variable should be on its own line for readability
  - Use proper indentation to align continuation lines
  - Break at logical points (commas, operators, etc.)
- **Example of proper line breaking:**
  ```crystal
  def initialize(@constitution : Int32 = 0,
                 @health : Int32 = 0,
                 @intelligence : Int32 = 0,
                 @luminosity : Int32 = 0,
                 @speed : Int32 = 0)
  ```

### Variable Ordering
- **Alphabetize parameters in initializers** wherever possible
- **Alphabetize getter declarations** to match initializer parameter order
- **Alphabetize named arguments** in method calls when practical
- This improves code readability and reduces merge conflicts

## JSON Formatting
- **ALL JSON must be multiline and properly formatted** for readability and maintainability
- **NEVER use single-line JSON** - always use proper indentation and line breaks
- **Use 2-space indentation** for JSON files consistently
- **Example of proper JSON formatting:**
  ```json
  {
    "name": "shield",
    "type": "positive",
    "effect_type": "Protection",
    "description": "Increases constitution and health",
    "calculation": {
      "constitution": "dice_roll",
      "health": "dice_roll"
    },
    "amount_calculation": "constitution + health"
  }
  ```
- **Configuration data should be in JSON fixture files** rather than hardcoded in source
- **All JSON files must validate** with proper syntax and structure

## Output Formatting
- **ALWAYS** use built-in Colorize module for console output formatting: https://crystal-lang.org/api/1.16.3/Colorize.html
- Add `require "colorize"` to source files (no shard dependency needed - it's built into Crystal)
- Use `.colorize(:color)` and `.bold` methods for better user experience
- Prefer Colorize module over raw ANSI escape codes
- **NEVER** add colorize as a shard dependency - use the built-in module only

# Development Workflow

## Pull Request Requirements
Starting immediately, ALL changes to project code must be made through pull requests. Direct pushes to the `main` branch are prohibited.

### Creating Pull Requests
1. **Create a feature branch** for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-bug-fix
   ```

2. **Make your changes** on the feature branch
3. **Test your changes** using Docker workflows:
   ```bash
   cd game_tests
   make docker-all  # Run build, test, and lint
   ```

4. **Commit your changes** with descriptive messages
5. **Push the branch** to GitHub:
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create a pull request** using GitHub CLI or web interface:
   ```bash
   gh pr create --title "Feature: Your feature description" --body "Detailed description of changes"
   ```

### Pull Request Requirements
- ✅ **All CI checks must pass** (docker-lint, docker-test, docker-integration-test)
- ✅ **At least 1 approving review** required
- ✅ **Branch must be up-to-date** with main before merging
- ✅ **All conversations must be resolved**
- ❌ **No force pushes** to main branch
- ❌ **No direct commits** to main branch

### Branch Protection
The `main` branch is protected with the following rules:
- Require pull request reviews before merging
- Require status checks to pass before merging
- Require conversation resolution before merging
- Include administrators (rules apply to all users)
- Prohibit force pushes and deletions

### Emergency Procedures
In case of critical production issues requiring immediate fixes:
1. Create a hotfix branch: `git checkout -b hotfix/critical-issue`
2. Make minimal necessary changes
3. Create PR with "HOTFIX" prefix and detailed justification
4. Request expedited review
5. Merge after CI passes and approval received

## Branch Naming Conventions
- **Features**: `feature/description` or `feat/description`
- **Bug fixes**: `fix/description` or `bugfix/description`
- **Hotfixes**: `hotfix/description`
- **Documentation**: `docs/description`
- **Refactoring**: `refactor/description`
- **Tests**: `test/description`

# important-instruction-reminders
Do what has been asked; nothing more, nothing less.
NEVER create files unless they're absolutely necessary for achieving your goal.
ALWAYS prefer editing an existing file to creating a new one.
NEVER proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User.

## CRITICAL: Pull Request Workflow Required
ALL code changes MUST be made through pull requests. Direct pushes to main branch are PROHIBITED.
1. Create feature branch: `git checkout -b feature/description`
2. Make changes and test with: `cd game_tests && make docker-all`
3. Push branch: `git push origin feature/description`
4. Create PR: `gh pr create --title "Feature: description" --body "Details"`
5. Wait for CI checks and approval before merging

Branch protection rules are enforced - direct commits to main will be rejected.