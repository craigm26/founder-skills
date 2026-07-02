# Worked example — PRD: Task Priority System

A complete example PRD in the exact shape `/prd` produces (fictional feature: priority levels for
a task-management app). Mirror this closely — especially the T-00n task format and the verifiable
acceptance criteria. This file would be saved as `/tasks/prd-task-priority-system.md`.

---

# PRD: Task Priority System

## Self-Clarification

1. **Problem/Goal:** Users can't tell which tasks matter most; everything looks equally urgent.
2. **Core Functionality:** Assign a priority to a task, see it at a glance, filter by it.
3. **Scope/Boundaries:** Three fixed levels only; no notifications, no auto-assignment.
4. **Success Criteria:** Priority changeable in under 2 clicks; high-priority tasks visually distinct without hovering.
5. **Constraints:** One additive migration; no changes to the existing task API shape.

## Introduction

Add priority levels to tasks so users can focus on what matters most.

## Goals

- Allow assigning priority (high/medium/low) to any task
- Provide clear visual differentiation between priority levels
- Enable filtering by priority

## Tasks

### T-001: Add priority field to database
**Description:** Add priority column to tasks table for persistence.

**Acceptance Criteria:**
- [ ] Add priority column: 'high' | 'medium' | 'low' (default 'medium')
- [ ] Generate and run migration successfully
- [ ] Quality checks pass

### T-002: Display priority indicator on task cards
**Description:** Show colored priority badge on each task card.

**Acceptance Criteria:**
- [ ] Each task card shows colored badge (red=high, yellow=medium, gray=low)
- [ ] Priority visible without hovering
- [ ] Quality checks pass
- [ ] Verify in browser

### T-003: Add priority selector to task edit
**Description:** Allow changing task priority in edit modal.

**Acceptance Criteria:**
- [ ] Priority dropdown in task edit modal
- [ ] Shows current priority as selected
- [ ] Saves on selection change
- [ ] Quality checks pass
- [ ] Verify in browser

## Functional Requirements

- FR-1: Add `priority` field to tasks table
- FR-2: Display colored priority badge on each task card
- FR-3: Include priority selector in task edit modal

## Non-Goals

- No priority-based notifications
- No automatic priority assignment

## Success Metrics

- Users can change priority in <2 clicks
- High-priority tasks immediately visible
