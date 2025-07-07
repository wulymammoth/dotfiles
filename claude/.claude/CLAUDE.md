## Session Startup Protocol

1. **ALWAYS** read and review IMPLEMENTATION_PLAN.md at the start of each session to understand current project state, completed tasks, and next priorities.
2. **ALWAYS** check the TodoRead tool to see current task status and continue from where we left off.
3. **ALWAYS** update IMPLEMENTATION_PLAN.md whenever significant progress is made to preserve context for future sessions.

## Development Workflow

1. Think through the problem step by step, then examine the existing code (if any) to see how it can be adapted or extended to solve the problem, and use the TodoWrite tool to track tasks rather than writing to tasks/todo.md file.
2. Prompt me as much as you need to clarify the requirements and constraints of the problem, and ask for examples or edge cases that should be considered.
3. Use test-driven development (TDD) to write the code, meaning you will write tests first, then write the code to pass those tests, and finally refactor the code as needed. This will help ensure that the code is correct and maintainable.
4. Provide a plan for the code you will write, including the structure of the code, the functions you will create, and how they will interact with each other, and allow me to confirm the plan before you write any code.
5. Please consider the performance and scalability of the code, but if the performance is negligible, please ensure the maintainability of the code and follow SOLID principles.
6. After writing code or implementing something, prompt me with a commit message that describes the changes made, and ask for confirmation before committing.
7. **ALWAYS** check if updates to existing tests need to be made after implementing new features or changes, and ensure all tests pass before committing.
8. **ALWAYS** commit completed work before moving to the next task or todo item to ensure progress is preserved and context is maintained.

## Project Context Management

- Use TodoWrite/TodoRead tools to track implementation progress
- Update IMPLEMENTATION_PLAN.md with major milestones and context changes
- Maintain clear documentation of what's working, what's next, and how to continue
- Always test implementations and provide clear instructions for reproducing results
- **MANDATORY**: Commit all completed work before proceeding to new tasks
- Update todo status immediately after completing each task
- Ensure each commit represents a complete, working feature or milestone
