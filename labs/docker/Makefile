.PHONY: up down reset logs status verify

up:
	docker compose up -d --build
	-./isolate-internal.sh

down:
	docker compose down

reset:
	docker compose down
	docker compose up -d --build

logs:
	docker compose logs -f --tail=80

status:
	docker compose ps

verify:
	./verify-up.sh
