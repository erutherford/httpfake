TEST_PACKAGES := $(shell go list ./...)
COVER_PACKAGES := $(shell go list ./... | paste -sd "," -)

install_gometalinter:
	@go get -v github.com/alecthomas/gometalinter
	@gometalinter --install

update_gometalinter:
	@go get -v -u github.com/alecthomas/gometalinter
	@gometalinter --install --update

## lint: Validate golang code
lint: install_gometalinter
	@gometalinter \
		--deadline=120s \
		--line-length=120 \
		--enable-all \
		--vendor ./...

## Perform all tests
test: test/unit

## Perform unit tests
test/unit:
	@go test -v -cover $(TEST_PACKAGES)

test/coverage:
	@for d in ${TEST_PACKAGES}; do \
		go test -v -coverpkg $(COVER_PACKAGES) -coverprofile=profile.out -covermode=atomic $$d; \
		if [ -f profile.out ]; then \
			cat profile.out >> coverage.out; \
			rm profile.out; \
		fi; \
	done

test/coverage/publish:
	@go get golang.org/x/tools/cmd/cover
	@go get github.com/mattn/goveralls
	@goveralls -coverprofile=coverage.out -service=travis-ci -repotoken $$COVERALLS_TOKEN
