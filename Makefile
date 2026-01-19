
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

lint-fix: format lint