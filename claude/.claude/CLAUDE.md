## Session Startup Protocol

1. **ALWAYS** read and review the following (if avaiable) at the start of each session to understand current project state, completed tasks, and next priorities:

- IMPLEMENTATION_PLAN.md
- .claude-context.md

2. **ALWAYS** check the TodoRead tool to see current task status and continue from where we left off.
3. **ALWAYS** update IMPLEMENTATION_PLAN.md whenever significant progress is made to preserve context for future sessions.

## Development Workflow

1. **ALWAYS** think through the problem step by step, then examine the existing code and existing tests (if any) to see how it can be adapted or extended to solve the problem, and use the TodoWrite tool to track tasks rather than writing to tasks/todo.md file.
2. **ALWAYS** use context7 to obtain up-to-date documentation for and most current official docs for libraries and frameworks
3. **ALWAYS** prompt me as much as you need to clarify the requirements and constraints of the problem, and ask for examples or edge cases that should be considered.
4. Use test-driven development (TDD) to write the code, meaning you will write tests first, then write the code to pass those tests, and finally refactor the code as needed. This will help ensure that the code is correct and maintainable.
5. Provide a plan for the code you will write, including the structure of the code, the functions you will create, and how they will interact with each other, and allow me to confirm the plan before you write any code.
6. **ALWAYS** consider the performance and scalability of the code, but if the performance is negligible, please ensure the maintainability of the code.
7. Follow SOLID design principles and best practices for clean code, including:

- Single Responsibility Principle: Each function or class should have one responsibility or reason to change
- Open/Closed Principle: Code should be open for extension but closed for modification
- Liskov Substitution Principle: Subtypes should be substitutable for their base types
- Interface Segregation Principle: Clients should not be forced to depend on interfaces they do not use
- Dependency Inversion Principle: High-level modules should not depend on low-level modules, but both should depend on abstractions

8. If something doesn't work, please check for existing examples and patterns in the codebase then follow them, and if necessary, ask for help or clarification before proceeding.
9. **ALWAYS** check if updates to existing tests need to be made after implementing new features or changes, and ensure all tests pass before committing.
10. After writing code or implementing something, prompt me with a commit message that describes the changes made, and ask for confirmation before committing.
11. **ALWAYS** update .claude-context.md to ensure that progress is preserved and context is maintained before committing completed and moving onto the next task or to-do

- This should always include any lessons learned, such as regressions, data access, particular bugs, context information about particular modules, the environment's confiugration, etc.

## Project Context Management

- Use TodoWrite/TodoRead tools to track implementation progress
- Update IMPLEMENTATION_PLAN.md with major milestones and context changes
- Maintain clear documentation of what's working, what's next, and how to continue
- Always test implementations and provide clear instructions for reproducing results
- **MANDATORY**: Commit all completed work before proceeding to new tasks
- Update todo status immediately after completing each task
- Ensure each commit represents a complete, working feature or milestone
