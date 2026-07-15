MAKEFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
PROJECTS_ROOT ?= $(abspath $(MAKEFILE_DIR)/..)

EXPENSE_TRACKER_DIR ?= $(PROJECTS_ROOT)/expense-tracker
PLAN_APP_DIR ?= $(PROJECTS_ROOT)/plan-visualizer
WORKOUT_APP_DIR ?= $(PROJECTS_ROOT)/routine-workout

.PHONY: start expense plan workout

# Start the two everyday applications concurrently.
start:
	+@$(MAKE) --no-print-directory -j2 expense plan

expense:
	@echo "Starting expense tracker at http://localhost:47830"
	@cd "$(EXPENSE_TRACKER_DIR)" && pnpm dev

plan:
	@echo "Starting plan application at http://localhost:4823"
	@cd "$(PLAN_APP_DIR)" && npm run dev

workout:
	@echo "Starting workout application at http://localhost:47131"
	@cd "$(WORKOUT_APP_DIR)" && pnpm dev
