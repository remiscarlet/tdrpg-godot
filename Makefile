
setup:
	@echo "Please download GDQuest's gdscript-formatter and place the binary in the 'tools/' directory."

install: setup

lint:
	find . -path './addons' -prune -o -name '*.gd' -type f -exec \
		./tools/gdscript-formatter lint \
		--disable function-name \
		--max-line-length 120 \
		{} \;

format:
	find . -path './addons' -prune -o -name '*.gd' -type f -exec \
		./tools/gdscript-formatter \
		--use-spaces \
		--reorder-code \
		{} \;

lint-fix: format lint lint-stringnames

lint-stringnames:
	python3 tools/lint_stringnames.py

test:
	godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a tests -rd res://tests/.reports

ci: lint-fix test
