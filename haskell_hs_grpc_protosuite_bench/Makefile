CABAL ?= cabal
PROTO_COMPILE_HS = ~/.cabal/bin/compile-proto-file

proto-suite:
	($(CABAL) build proto3-suite && mkdir -p ~/.cabal/bin && \
		$(CABAL) exec which compile-proto-file | tail -1 | xargs -I{} cp {} $(PROTO_COMPILE_HS))
	($(PROTO_COMPILE_HS) \
		--includeDir /usr/local/include \
		--includeDir ../proto/helloworld \
		--proto helloworld.proto \
		--out ./src-gen/)
	# XXX: Remove unused grpc function and imports
	(sed -i \
		-e '/^greeterServer/,/^\s*$$/d' \
		-e '/^greeterClient/,/^\s*$$/d' \
		-e '/^data Greeter/,/^\s*$$/d' \
		-e '/^import Network.GRPC/,/^[^import]/d' \
		./src-gen/Helloworld.hs \
	)
