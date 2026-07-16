# Portable launcher for the everyday projects.
#
# This is the canonical copy (version-controlled in the dotfiles repo) so it
# travels to any laptop/device. It assumes the projects live as siblings of
# this dotfiles directory; override the *_DIR paths below if that changes.
#
# Combined commands:
#   make apps      -> runs Expense Tracker + Plan Visualizer together
#   make workout   -> runs the Routine Workout project
#
# Individual commands (one per project):
#   make expense   -> runs only the Expense Tracker
#   make plan      -> runs only the Plan Visualizer
#   make routine   -> runs only the Routine Workout

MAKEFILE_DIR  := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
PROJECTS_ROOT ?= $(abspath $(MAKEFILE_DIR)/..)

EXPENSE_TRACKER_DIR ?= $(PROJECTS_ROOT)/expense-tracker
PLAN_APP_DIR        ?= $(PROJECTS_ROOT)/plan-visualizer
WORKOUT_APP_DIR     ?= $(PROJECTS_ROOT)/routine-workout

.PHONY: help apps workout expense plan routine

# Default target: list available commands
help:
	@echo "Available commands:"
	@echo "  make apps      Run Expense Tracker + Plan Visualizer together"
	@echo "  make workout   Run the Routine Workout project"
	@echo ""
	@echo "  make expense   Run only the Expense Tracker"
	@echo "  make plan      Run only the Plan Visualizer"
	@echo "  make routine   Run only the Routine Workout"

# --- Combined command: Expense Tracker + Plan Visualizer -----------------------
# Runs both dev servers concurrently; Ctrl-C stops both.
apps:
	@echo "Starting Expense Tracker + Plan Visualizer..."
	+@$(MAKE) --no-print-directory -j2 expense plan

# --- Separate command: Routine Workout -----------------------------------------
workout: routine

# --- Individual project commands ----------------------------------------------
expense:
	@echo "Starting expense tracker at http://localhost:47830"
	@cd "$(EXPENSE_TRACKER_DIR)" && pnpm dev

plan:
	@echo "Starting plan visualizer at http://localhost:4823"
	@cd "$(PLAN_APP_DIR)" && pnpm dev

routine:
	@echo "Starting routine workout at http://localhost:47131"
	@cd "$(WORKOUT_APP_DIR)" && pnpm dev
