## Session Startup Protocol

1. **ALWAYS** read and review the following (if available) at the start of each session to understand current project state, completed tasks, and next priorities:

- `<project or repo name>/README.md`
- `<project or repo name>/<current branch name>.md`
- `CLAUDE.local.md`
- `.claude-context.md`

## Tool Preferences

- use `fd` utility instead of `find` for file searching (fallback to `find` if `fd` unavailable)
- use `rg` instead of `grep` for searching text
- use Context7 to obtain up-to-date documentation for libraries and frameworks
- use TodoWrite tool to track implementation progress

## Context Management

**`.claude-context.md`** (project-wide, committed):

- Regression patterns, root causes, and prevention strategies
- Module architecture decisions, quirks, dependencies, gotchas
- Data access patterns, schema insights, query optimization lessons
- Bug fixes with root cause analysis and solution approaches

**`CLAUDE.local.md`** (environment-specific, not committed):

- Local environment configurations (database URLs, API endpoints, file paths)
- Machine-specific setup details (OS differences, tool versions, personal dev setup)
- Local data access credentials and connection strings

**Progress tracking:**

- Update `~/Desktop/notes/<branch name>--<current date>.md` with major milestones and context changes
- Maintain clear documentation of what's working, what's next, and how to continue
- Update todo status immediately after completing each task

## Development Workflow

1. **ALWAYS** think through the problem step by step, then examine the existing code and existing tests (if any) to see how it can be adapted or extended to solve the problem.
2. **ALWAYS** prompt me as much as you need to clarify the requirements and constraints of the problem, and ask for examples or edge cases that should be considered.
3. Use test-driven development (TDD) to write the code, meaning you will write tests first, then write the code to pass those tests, and finally refactor the code as needed.
4. Provide a plan for the code you will write, including the structure of the code, the functions you will create, and how they will interact with each other, and allow me to confirm the plan before you write any code.
5. **ALWAYS** consider the performance and scalability of the code, but if the performance is negligible, please ensure the maintainability of the code.
6. Follow SOLID design principles and best practices for clean code:
   - Single Responsibility Principle: Each function or class should have one responsibility or reason to change
   - Open/Closed Principle: Code should be open for extension but closed for modification
   - Liskov Substitution Principle: Subtypes should be substitutable for their base types
   - Interface Segregation Principle: Clients should not be forced to depend on interfaces they do not use
   - Dependency Inversion Principle: High-level modules should not depend on low-level modules, but both should depend on abstractions
7. If something doesn't work, please check for existing examples and patterns in the codebase then follow them, and if necessary, ask for help or clarification before proceeding.
8. **ALWAYS** check if updates to existing tests need to be made after implementing new features or changes, and ensure all tests pass before committing.
9. After writing code or implementing something, prompt me with a commit message that describes the changes made, and ask for confirmation before committing.
10. **ALWAYS** update context files before committing completed work and moving on to the next task.

## Commit Standards

- **MANDATORY**: Commit all completed work before proceeding to new tasks
- Ensure each commit represents a complete, working feature or milestone
- Always test implementations and provide clear instructions for reproducing results
