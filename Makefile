all: ./out/static-xarexec.tgz

xarexec-build: docker/Dockerfile docker/build.sh
	@echo Build docker image
	@docker build -t $@ --file $< docker/

./out/static-xarexec.tgz: xarexec-build
	@mkdir -p out dl
	@echo Building: $@
	docker run --rm -v `pwd`/out:/out -v `pwd`/dl:/dl $< /$@
	@echo "Files should be in: " $@
	@tar tzvf $@

debug: xarexec-build
	@mkdir -p out dl
	@docker run --entrypoint "/bin/sh" --rm -ti -v `pwd`/out:/out -v `pwd`/dl:/dl $<

clean:
	@echo Removing image xarexec-build
	@docker rmi xarexec-build 2> /dev/null || true
	@echo Removing static-xarexec.tgz
	@rm -f static-xarexec.tgz

.PHONY: all clean xarexec-build
