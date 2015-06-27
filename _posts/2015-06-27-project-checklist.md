---
layout: post
title: "Project Health Checklist"
---

I am constantly evaluating new projects at work and at home.
After seeing enough both good and bad, I have started to develop a mental checklist to evaluate the maturity of a software project.
This quick evaluation can be useful from the extremes of joining a new team to evaluating a new library.
It's not meant to be exhaustive.
Instead, I use the answers to set expectations and quickly orient myself in unfamiliar surroundings.

```
# Project Health

## Source Control and Build
- Where can I find the project in source control?
- What do I need to build the project?
- Can I build the project with a single command?
- Can I deploy the project with a single command?
    - Even better, is the project automatically built and deployed?

## Tests
- Where can I find the integration tests for the project?
- Where can I find the unit tests for the project?
- Can I run the tests with a single command?
- Are the tests part of a CI server?

## Communication
- Where is the project backlog?
- Where is the bug tracking system?
- How do developers communicate on a day-to-day basis?

# Commonly Overlooked Items

## Internationalization
- Will the project be used by users of different cultures?
- How should the project look/behave for these users?
    - Text
    - Numbers
    - Dates
    - Sorting (client, server, and database)

## Performance
- What kind of loads should the project expect to see?
    - Throughput
    - Length
    - Regularity
- Has the system been profiled under these loads?
```

I will try to keep this post up to date as I add to the list.  What are some of the items in your personal checklist?

