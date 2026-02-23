# Universal Code Review Method

## Overview

This method provides a systematic approach to reviewing any codebase and adding constructive TODO comments for improvement. The focus is on **practical improvements** that enhance readability, maintainability, and immediate functionality - not over-engineering for hypothetical future scenarios.

## Step 1: Initial Context Gathering

### Ask These Questions First

1. **What type of application is this?** (web app, mobile app, CLI tool, library, API, etc.)
2. **What is the main purpose/business domain?** (e.g., e-commerce, social media, data processing)
3. **Who are the primary users?** (end users, developers, internal team)
4. **What's the current development stage?** (prototype, MVP, production, legacy)
5. **Are there any specific concerns?** (performance, security, scalability, maintainability)
6. **What's the most painful part of this codebase for you right now?** (lack of clear architecture, responsibility separation, difficulty adding features, low maintainability, poor readability)

### Initial Discovery

- Search for and read `README.md` (if exists)
- Look for package.json, requirements.txt, or equivalent dependency files
- Check for configuration files (tsconfig.json, .eslintrc, etc.)

## Step 2: Architecture Understanding

### Map the Structure

- Identify main directories and their purposes
- Find the entry point(s) of the application
- Understand high-level data flow, main components and overall architecture

### Ask Clarifying Questions (if unclear)

- "The [component] seems to handle multiple responsibilities - should I focus on separation of concerns?"
- "I notice [pattern] - are you open to refactoring suggestions or should I focus on smaller improvements?"

## Step 3: Analyze all files in the repository

- Analyze all files in the repository:
  - Source code
  - Tests
  - Documentation
  - Configuration files

### Areas of improvement

- Architecture
  - Spot multiple responsibilities in a single component or module
  - Spot missing abstractions that provide clear separation of concerns
  - Spot abstractions that render code unreadable and complicated to perceive
- Code shape
  - Are variable/t pfunction names clear and descriptive or confusing?
  - Is the code self-documenting or unclear?
  - Is the control flow easy to follow or convoluted?
  - Is there code duplication?
  - Is code nested too deeply or just enough to keep it readable?
  - Functions or classes that are too long (can be broken down)  
- Safety & Reliability
  - Missing error handling that could cause crashes
  - Input validation gaps that could cause bugs (input sanitization)
  - Resource leaks (unclosed connections, memory leaks)
  - Race conditions or threading issues
  - Null/undefined checks where needed
  - Type safety improvements (if applicable)
  - Proper error messages for user to understand not only what is wrong but to have a clear path towards correct action
- Functionality
  - Missing test cases
  - Logical branches where execution could go into untested or dangerous paths
- Developer Experience
  - Missing documentation for complex functions and classes
  - Hard-coded values that should be configurable

### General considerations

#### KISS (Keep It Simple, Stupid)

- Prefer simple solutions
- Choose clarity over cleverness
- Don't suggest complex design patterns for simple problems
- Don't propose major architectural changes unless necessary and providing big wins
- Don't optimize prematurely (focus on clarity first)
- Don't add abstractions for future scenarios that may never happen

#### YAGNI (You Aren't Gonna Need It)

- Don't build for future scenarios
- Don't optimize prematurely
- Don't abstract without concrete need or win
- Don't propose scalability solutions for current scale
- Don't recommend complex caching for simple applications
- Don't design for multi-tenancy if it's a single-tenant app

## Step 4: Add TODOs

### For Each File

1. **Read the entire file first** to understand context
2. **Identify the main purpose** of the file
3. **Look for obvious issues** (crashes, bugs, security)
4. **Check for readability** and clarity
5. **Add 2-5 targeted TODOs** (don't overwhelm)
6. **Move to the next file**

### When to Ask Questions

- "I see [pattern] repeated 3+ times - is this worth extracting or is it fine as-is?"
- "This error handling is basic but functional - should I suggest improvements or keep it simple?"
- "The architecture seems to work but could be cleaner - what's your priority: simplicity or structure?"

### The TODO Format

```javascript
// TODO: [Specific, actionable improvement] - [Brief reason/benefit]
// TODO: Consider [optional enhancement] - [Why this might help]
// TODO: Add [missing functionality] - [What's missing and why it matters]
```

### Examples of Good TODOs

```javascript
// TODO: Add input validation for email format - prevents invalid data
// TODO: Extract this magic number to a named constant - improves readability
// TODO: Add error handling for network requests - prevents crashes
// TODO: Consider adding pagination for large lists - improves performance
```

### Examples of Bad TODOs (avoid these)

```javascript
// TODO: Make this better (too vague)
// TODO: Implement microservices architecture (over-engineering)
// TODO: Add AI-powered recommendations (future speculation)
// TODO: Rewrite everything in Rust (unrealistic scope)
```

## Step 5: Provide Final Summary

### Create a Summary Document

1. **Overall assessment** (what's done well)
2. **Top 3-5 priority improvements** (most impactful, on big scale)
3. **Learning opportunities** (what the developers can focus on)
4. **Next steps** (what to tackle first)

### Keep the Summary Practical

- Focus on actionable advice
- Highlight what's already working well
- Provide clear next steps
- Avoid overwhelming with too many suggestions
