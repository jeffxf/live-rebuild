serve:
	@echo "Starting app..."
	@$(APP_NAME) &
	@echo "Watching for changes..."
	@fswatch -xrn -m inotify_monitor --event Created --event Removed --event Updated --event Renamed src/ | xargs -n 1 -I {} make restart || make kill

build:
	@echo "Rebuilding app..."
	@if [ ! -d "src/vendor/" ]; then go get -v ./... ; fi
	@go build -i -o $(GOPATH)/bin/$(APP_NAME) -v src/main.go
	@echo "Built new app..."

kill:
	@echo "Killing old app..."
	@pkill $(APP_NAME) || true
	@echo "Killed old app..."

restart: build kill
	@echo "Starting new app..."	
	@$(APP_NAME) &

.PHONY: serve restart kill build
