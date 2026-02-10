# Git Branching Strategy - Offerte-Maker-Api

## Overview

This document defines the Git workflow for the Offerte-Maker-Api project. It integrates with the architecture enforcement system (Architect and Developer agents) to ensure every feature is built correctly.

**Key principle:** Every feature branch must pass automated checks and Architect approval before merging to main.

---

## Branch Types

### 1. **Main Branch** (`main`)
- **Purpose:** Production-ready code
- **Protection:** Requires PR review + Architect approval
- **Merges from:** Release branches and hotfixes only
- **Tags:** Semantic versioning (v1.0.0, v1.0.1, etc.)

### 2. **Development Branch** (`develop`)
- **Purpose:** Integration point for features
- **Protection:** Requires PR review
- **Merges from:** Feature branches
- **Deployment:** Staging/QA environment

### 3. **Feature Branches** (`feature/*`)
- **Purpose:** Individual feature development
- **Naming:** `feature/quotes`, `feature/invoice-generation`, etc.
- **Created from:** `develop`
- **Merged to:** `develop` (via PR)
- **Review process:** Automated + Architect agent

### 4. **Bugfix Branches** (`bugfix/*`)
- **Purpose:** Fix non-critical bugs during development
- **Naming:** `bugfix/swagger-xml-path`, `bugfix/migration-assembly`, etc.
- **Created from:** `develop`
- **Merged to:** `develop` (via PR)
- **Review process:** Same as features

### 5. **Release Branches** (`release/*`)
- **Purpose:** Prepare for production release
- **Naming:** `release/1.0.0`, `release/1.1.0`, etc.
- **Created from:** `develop`
- **Merged to:** `main` and back to `develop`
- **Activities:** Version bumps, final testing, hotfixes

### 6. **Hotfix Branches** (`hotfix/*`)
- **Purpose:** Emergency fixes to production
- **Naming:** `hotfix/critical-bug`, `hotfix/security-vulnerability`, etc.
- **Created from:** `main`
- **Merged to:** `main` and `develop`
- **Review process:** Expedited (Architect review still required)

---

## Workflow Diagram

```
main ────────────────────────────────────────────────────────►
      ↑                                                    ↑
      │ merge (release)                    merge (release)
      │                                                    │
release/1.0.0 ─────────────────────────────────────────────┤
                                                           │
develop ────────────────────────────────────────────────────►
   ↑                    ↑                    ↑
   │ PR merge          │ PR merge           │ PR merge
   │                   │                    │
feature/quotes ───────┘  bugfix/issue-123  feature/invoices ──────►

      Feature development branches
      - Created from develop
      - Deleted after merge
      - Require PR + Architect approval
```

---

## Feature Branch Workflow

### Step 1: Create Feature Branch

```bash
# Update develop to latest
git checkout develop
git pull origin develop

# Create feature branch from develop
git checkout -b feature/quotes

# Example: feature/quotes
# Example: feature/invoice-generation
# Example: feature/user-authentication-v2
```

**Naming conventions:**
- Use lowercase
- Separate words with hyphens
- Be specific and descriptive
- Max 50 characters: `feature/customer-payment-method`

### Step 2: Build Feature Following Architecture

Follow the workflow in **DEVELOPMENT_GUIDELINES.md**:

1. Read `ARCHITECT_CHECKLIST.md`
2. Create all 6 layers:
   - Entity (Domain Layer)
   - Repository (Data Access)
   - Service (Business Logic)
   - DTOs (Data Transfer)
   - Controller (Presentation)
   - AutoMapper configuration

3. Ensure code quality:
   - All namespaces: `OfferteMakerApi.*`
   - Async/await throughout
   - Proper error handling
   - XML documentation on public methods

### Step 3: Commit to Feature Branch

**Commit message format:**

```
feat: Add quotes API endpoint

- Create Quote entity with GUID primary key
- Implement IQuoteRepository with CRUD operations
- Add QuoteService with business logic
- Create QuoteDto, CreateQuoteDto, UpdateQuoteDto
- Implement QuotesController with GET, POST, PUT, DELETE
- Add AutoMapper configuration
- Wire everything through ServiceManager and RepositoryManager

Closes #123
```

**Commit message rules:**
- Start with `feat:`, `fix:`, `refactor:`, `docs:`, etc.
- Keep first line under 72 characters
- Explain *why*, not just *what*
- Reference GitHub issues if applicable: `Closes #123`

**Multiple commits are OK:**
```bash
git add OfferteMakerApi/Entities/Models/Quote.cs
git commit -m "feat: Add Quote entity"

git add OfferteMakerApi/Repository/
git commit -m "feat: Add QuoteRepository implementation"

git add OfferteMakerApi/Service/
git commit -m "feat: Add QuoteService business logic"

# Etc...
```

### Step 4: Run Pre-Submission Checks

Before pushing, validate your feature:

```bash
# Run automated compliance check
./scripts/architect-review.sh quotes

# Expected output:
# ✓ PASSED: 15/15 checks
# Status: Ready for Architect Agent review
```

**If checks fail:** Fix issues and re-run until all pass.

### Step 5: Push Feature Branch

```bash
# Push to remote
git push -u origin feature/quotes

# The `-u` flag sets upstream tracking
```

### Step 6: Create Pull Request

```bash
# Using GitHub CLI
gh pr create \
  --title "feat: Add quotes API" \
  --body "## Summary
Added complete quotes feature with all CRUD operations.

## Changes
- Quote entity with proper relationships
- Repository pattern with full CRUD
- Service layer with business logic
- DTOs for API requests/responses
- QuotesController with full documentation
- AutoMapper integration

## Testing
- All endpoints tested manually
- Swagger documentation present
- Error handling verified

## Architecture Compliance
✓ Ran ./scripts/architect-review.sh quotes
✓ All 15 checks passed

Closes #123" \
  --base develop
```

**Or through GitHub web interface:**

1. Go to https://github.com/yourusername/offerte-maker-api/compare/develop...feature/quotes
2. Click "Create Pull Request"
3. Fill in title and description
4. Ensure base is `develop`, compare is `feature/quotes`
5. Click "Create Pull Request"

### Step 7: Automated Checks Run

GitHub Actions will automatically:
- Run `dotnet build` to verify compilation
- Run tests (if configured)
- Generate automated review summary

### Step 8: Architect Agent Reviews PR

The **Architect Agent** will:

1. **Verify all checklist items:**
   - Entity layer complete
   - Repository layer correct
   - Service layer follows patterns
   - DTOs present and proper
   - Controller fully documented
   - AutoMapper configured

2. **Output approval or rejection:**

**APPROVED:**
```
✅ APPROVED

All requirements met:
✓ Entity layer complete
✓ Data access layer complete
✓ Business logic layer complete
✓ Presentation layer complete
✓ DTOs present
✓ Code quality standards met

Status: Ready to merge
```

**REJECTED:**
```
❌ REJECTED

Issues found:

1. Missing Service Interface
   → Create: Service.Contracts/IQuoteService.cs
   → Reference: ARCHITECT_CHECKLIST.md → Business Logic Layer

Developer: Fix these issues and push new commits to this PR.
```

### Step 9: Code Review

Additional code review by team members may occur. Address feedback by pushing new commits:

```bash
# Make changes based on feedback
git add .
git commit -m "review: Address feedback on quote validation"
git push origin feature/quotes
```

PR will automatically update with new commits.

### Step 10: Merge to Develop

Once Architect approves and reviews pass:

1. **Squash and merge** (recommended for feature branches):
   ```bash
   # Via GitHub UI:
   # Click "Squash and merge" button
   ```

2. **Or regular merge** (if you want to preserve commit history):
   ```bash
   git checkout develop
   git pull origin develop
   git merge --no-ff feature/quotes
   git push origin develop
   ```

3. **Delete feature branch:**
   ```bash
   # Via GitHub UI: Auto-deleted after merge
   # Or manually:
   git push origin --delete feature/quotes
   git branch -d feature/quotes
   ```

---

## Release Workflow

### When Ready for Release

1. **Create release branch from develop:**
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b release/1.0.0
   ```

2. **Update version numbers:**
   - Update `.csproj` files `<Version>1.0.0</Version>`
   - Update `README.md` with new version
   - Update `CHANGELOG.md` if present

3. **Commit version changes:**
   ```bash
   git add *.csproj README.md
   git commit -m "chore: Bump version to 1.0.0"
   git push -u origin release/1.0.0
   ```

4. **Create PR from release branch to main:**
   ```bash
   gh pr create --title "release: Version 1.0.0" \
     --base main \
     --head release/1.0.0
   ```

5. **Final testing & approval:**
   - Run full test suite
   - Architect reviews final code
   - All checks must pass

6. **Merge to main:**
   ```bash
   # Via GitHub UI: Merge to main
   ```

7. **Tag the release:**
   ```bash
   git checkout main
   git pull origin main
   git tag -a v1.0.0 -m "Release version 1.0.0"
   git push origin v1.0.0
   ```

8. **Merge back to develop:**
   ```bash
   git checkout develop
   git pull origin develop
   git merge main
   git push origin develop
   ```

9. **Delete release branch:**
   ```bash
   git push origin --delete release/1.0.0
   ```

---

## Hotfix Workflow

For critical production bugs:

1. **Create hotfix branch from main:**
   ```bash
   git checkout main
   git pull origin main
   git checkout -b hotfix/critical-security-issue
   ```

2. **Fix the bug:**
   - Make minimal, focused changes
   - Follow architecture guidelines
   - Write clear commit messages

3. **Bump patch version:**
   ```bash
   # Change 1.0.0 → 1.0.1
   git add *.csproj
   git commit -m "chore: Bump version to 1.0.1"
   ```

4. **Merge to main (expedited):**
   ```bash
   gh pr create --title "hotfix: Security issue in quote validation" \
     --base main \
     --head hotfix/critical-security-issue
   ```

5. **After approval and merge:**
   ```bash
   git checkout main
   git pull origin main
   git tag -a v1.0.1 -m "Hotfix: Security issue"
   git push origin v1.0.1
   ```

6. **Merge back to develop immediately:**
   ```bash
   git checkout develop
   git pull origin develop
   git merge main
   git push origin develop
   ```

---

## Commit Message Format

**Standard format (Conventional Commits):**

```
<type>: <subject>

<body>

<footer>
```

**Types:**
- `feat:` - New feature
- `fix:` - Bug fix
- `refactor:` - Code refactoring without feature change
- `docs:` - Documentation changes
- `test:` - Adding or updating tests
- `chore:` - Dependencies, build tools, etc.
- `perf:` - Performance improvements

**Examples:**

```bash
# Feature
git commit -m "feat: Add quote API endpoint"

# Bugfix
git commit -m "fix: Correct decimal precision in quote calculations"

# Refactoring
git commit -m "refactor: Extract quote validation logic to service"

# Documentation
git commit -m "docs: Update API documentation for quote endpoints"

# Multiple lines with details
git commit -m "feat: Add quote approval workflow

- Add QuoteStatus enum (Draft, Pending, Approved, Rejected)
- Implement approval logic in QuoteService
- Add ApproveQuote and RejectQuote controller endpoints
- Update QuoteDto to include status
- Add audit trail for approvals

Closes #456"
```

---

## Common Scenarios

### Scenario 1: Feature Branch Falls Behind Develop

```bash
# Update your branch with latest develop
git checkout feature/quotes
git fetch origin
git rebase origin/develop

# Or if you prefer merge over rebase
git merge origin/develop

# Push updates
git push origin feature/quotes
```

### Scenario 2: Need to Switch Branches

```bash
# Stash uncommitted changes
git stash

# Switch to another branch
git checkout develop

# Later, restore your changes
git stash pop
```

### Scenario 3: Accidentally Committed to Main

```bash
# Create a new branch with your commits
git checkout -b feature/accidentally-committed
git push -u origin feature/accidentally-committed

# Reset main to before your commits
git checkout main
git reset --hard origin/main

# Now create PR from your feature branch
```

### Scenario 4: Merge Conflict

```bash
# Update your branch
git checkout feature/quotes
git fetch origin
git rebase origin/develop

# Git will pause on conflicts
# Fix the conflicting files
# Then continue rebase
git rebase --continue

# Or abort if needed
git rebase --abort
```

---

## Branch Protection Rules (GitHub Settings)

**For `main` branch, enforce:**

- ✅ Require pull request reviews before merging
  - Minimum 1 review required (can be Architect Agent)
  - Dismiss stale pull request approvals
  - Require review from code owners

- ✅ Require status checks to pass before merging
  - CI/CD pipeline must pass
  - All automated checks must succeed

- ✅ Require conversation resolution before merging
  - All comments must be resolved

- ✅ Require branches to be up to date before merging
  - Prevents stale merges

- ✅ Dismiss stale pull request approvals when new commits are pushed

- ✅ Restrict who can push to matching branches
  - Admins only

**For `develop` branch, enforce:**

- ✅ Require pull request reviews before merging (less strict)
  - Any team member can approve

- ✅ Require status checks to pass

---

## Best Practices

### 1. Keep Feature Branches Focused
- One feature = one branch
- Each PR should be reviewable in < 30 minutes
- Avoid mixing features, refactoring, and bugfixes

### 2. Regular Commits
```bash
# Good: Multiple focused commits
git commit -m "feat: Add Quote entity"
git commit -m "feat: Add QuoteRepository"
git commit -m "feat: Add QuoteService"

# Not good: One huge commit
git commit -m "feat: Add everything"
```

### 3. Descriptive Commit Messages
```bash
# Good
git commit -m "fix: Handle null customer reference in quote calculation

Previously, quotes with null customer would throw NullReferenceException.
Now gracefully handles this case by using default customer tier."

# Not good
git commit -m "fix: bug"
```

### 4. Update Branch Before PR
```bash
# Ensure you're up to date with develop
git checkout develop
git pull origin develop
git checkout feature/quotes
git rebase origin/develop
```

### 5. Push Regularly
```bash
# Don't wait until feature is done
git push -u origin feature/quotes
# Then push updates as you commit
git push origin feature/quotes
```

### 6. Reference Issues
```bash
# Link commits to GitHub issues
git commit -m "feat: Add quote validation

Closes #123"

# Later when merging:
# GitHub will automatically close issue #123
```

---

## Architecture Integration

Every feature branch must:

1. **Pass automated checks:**
   ```bash
   ./scripts/architect-review.sh featurename
   ```

2. **Get Architect approval:**
   - Architect Agent reviews PR
   - Checks against `ARCHITECT_CHECKLIST.md`
   - Approves or requests changes

3. **Follow code standards:**
   - Namespaces: `OfferteMakerApi.*`
   - All methods async (`Task<T>`)
   - DTOs only in API (no entities)
   - Constructor injection
   - XML documentation

4. **Include tests** (if applicable):
   - Unit tests for service logic
   - Integration tests for controllers
   - Push tests with feature

---

## Summary

```
┌─────────────────────────────────────────────────────┐
│  Your Branch: feature/quotes                       │
│  Merge Target: develop                             │
│  Protection Level: Medium                          │
└─────────────────────────────────────────────────────┘

Step 1: Create feature branch from develop
Step 2: Build feature (6 layers minimum)
Step 3: Commit with clear messages
Step 4: Run ./scripts/architect-review.sh quotes
Step 5: Push to origin
Step 6: Create PR with good description
Step 7: Architect Agent reviews & approves
Step 8: Address feedback if needed
Step 9: Merge to develop (squash recommended)
Step 10: Delete feature branch

When ready for release:
→ Create release/X.X.X from develop
→ PR to main with version bump
→ Tag release on main
→ Merge back to develop
```

---

## Questions & Troubleshooting

**Q: Can I push directly to main?**
A: No. Branch protection rules prevent this. Always use feature branches and PRs.

**Q: What if architect rejects my PR?**
A: Read the feedback, fix the issues, and push new commits. The PR will update automatically.

**Q: Should I rebase or merge?**
A: Rebase is cleaner for feature branches. Main branches use merges to preserve history.

**Q: How long should feature branches exist?**
A: Aim for < 1 week. Longer branches increase merge conflict risk.

**Q: Can multiple people work on one feature branch?**
A: Yes, but communicate clearly. Consider splitting large features into smaller PR chunks.

---

## Related Documentation

- **ARCHITECT_CHECKLIST.md** - What every feature must include
- **DEVELOPMENT_GUIDELINES.md** - How to build features
- **ARCHITECTURE.md** - Why the architecture works this way
- **.claude/architect-agent.md** - How Architect reviews features
- **.claude/developer-agent.md** - How to build features correctly

---

**Last Updated:** February 10, 2026
**Status:** Active and enforced
