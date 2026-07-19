# Portable launcher for the everyday projects.
#
# This is the canonical copy (version-controlled in the dotfiles repo) so it
# travels to any laptop/device. It assumes the projects live as siblings of
# this dotfiles directory; override the *_DIR paths below if that changes.
#
# Combined commands:
#   make apps      -> runs Expense Tracker + SpecLens together
#
# Individual commands (one per project):
#   make expense   -> runs only the Expense Tracker
#   make speclens  -> runs only SpecLens
#   make workout   -> runs only Routine Workout

MAKEFILE_DIR  := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
PROJECTS_ROOT ?= $(abspath $(MAKEFILE_DIR)/..)

EXPENSE_TRACKER_DIR ?= $(PROJECTS_ROOT)/expense-tracker
SPEC_LENS_DIR       ?= $(PROJECTS_ROOT)/spec-lens
ROUTINE_WORKOUT_DIR ?= $(PROJECTS_ROOT)/routine-workout

.PHONY: help apps expense speclens workout

# Default target: list available commands
help:
	@echo "Available commands:"
	@echo "  make apps      Run Expense Tracker + SpecLens together"
	@echo ""
	@echo "  make expense   Run only the Expense Tracker"
	@echo "  make speclens  Run only SpecLens"
	@echo "  make workout   Run only Routine Workout"

# --- Combined command: Expense Tracker + SpecLens ------------------------------
# Runs both dev servers concurrently; Ctrl-C stops both.
apps:
	@echo "Starting Expense Tracker + SpecLens..."
	+@$(MAKE) --no-print-directory -j2 expense speclens

# --- Individual project commands ----------------------------------------------
expense:
	@echo "Starting Expense Tracker at http://expense.hebbars.in"
	@cd "$(EXPENSE_TRACKER_DIR)" && pnpm dev

speclens:
	@echo "Starting SpecLens at http://spec.lens.hebbars.in"
	@cd "$(SPEC_LENS_DIR)" && pnpm dev

workout:
	@echo "Starting Routine Workout at http://routine.hebbars.in"
	@cd "$(ROUTINE_WORKOUT_DIR)" && pnpm dev
