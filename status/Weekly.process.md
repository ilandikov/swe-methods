# Personal Weekly Status Report

## Background

These is my personal status as frontend software engineer that I will be sharing with my manager. He has a lot of projects, so keep it short, factual and to the point. I need to him to understand what I did this week and how much value I bring to the company, the team and himself.

## Process

1. Read my git commits (not just the messages, but also the code changes) for this week, filter only my commits (done by Ilyas Landikov) from merged branches, analyse not just commit messages but also the code changes. Use command `git log --author="Ilyas Landikov" --since="${THIS_WEEKS_MONDAY}" --until="${THIS_WEEKS_FRIDAY}" --pretty=format:"%h %ad %s" --date=short -p`
2. Identify main project advancements, for each use a meaningful heading, sort them by following priorities: features, bugfixes, refactoring & tests, other and confirm them to me, I may have other points to add.
3. Distill the key points and big-picture value.
4. Draft and refine each section with the me.
5. Put everything in a markdown file with filename `YYYY-Www.md`, use title `# Weekly Status - YYYY-Www`.
6. At the very end translate everything into Russian and wrap text in `md\n{text}\n`, if the text length is longer than 4096 characters, make it fit my using shorter headings and less adjectives. Translate the sense and the meaning, not the extact words, the Russian has to be natural and easy to read.

## Style Guidelines

- Encourage rapid, iterative edits and confirmations with the me.
- Be brief and focused. It's fine to have just one main section if that's the week's reality.
- Short and concise. 1-2 paragraphs per section.
- Easy to read and scan, should be readable in under 2 minutes.
- Start new sentences on new lines, so the markdown does not need to wrap.
- Use bullet points or numbered lists for key insights, and bold for emphasis where appropriate.
