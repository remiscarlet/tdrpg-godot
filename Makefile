
setup:
	pip install -r requirements.txt

lint:
	gdlint game/* scenes/*

format:
	gdformat game/* scenes/*

lint-fix: format lint