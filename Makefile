### Add functions here and link them to builder-bit format MUST BE "build-FunctionResourceName in template.yaml"

build-WaterMonitor: builder-bot

######################  No Change required below this line  ##########################

file := id_rsa 
#SSH_KEY := $(shell cat ${file}) #Use this to get value from shell command. This expands newlines to white spaces which doens't work for ssh keys.

builder-bot:
	$(eval $@PRODUCT = $(subst build-,,$(MAKECMDGOALS)))
	$(eval $@BUILD_DIR = $(PWD)/.aws-sam/build-$($@PRODUCT))
	$(eval $@STAGE = $($@BUILD_DIR)/lambda)
	$(eval $@ARTIFACTS_DIR = $(PWD)/.aws-sam/build/$($@PRODUCT))
	
	# Create docker file
	#docker build -f Dockerfile . -t builder --build-arg SSH_PRIVATE_KEY="$(SSH_KEY)"
	docker build --platform linux/arm64 -f Dockerfile . -t builder

	# prep directories
	mkdir -p $($@BUILD_DIR)/lambda $($@ARTIFACTS_DIR)

	# Compile application
  # Remove the -l from back command as thought it was causing issues with swift package but not sure if any relation?? 'l' invokes a login shell
	docker run --platform linux/arm64 --rm -v $($@BUILD_DIR):/build-target -v `pwd`:/build-src -w /build-src builder bash -c "swift package resolve -v; swift build --product $($@PRODUCT) -c release --build-path /build-target"

	# copy deps
  # For some reason the awk statement fails if you run this Makefile directly without aws sam?
  # Also the docker command below will fail without the "-" before it?
	-docker run --platform linux/arm64 --rm -v $($@BUILD_DIR):/build-target -v `pwd`:/build-src -w /build-src builder bash -cl "ldd '/build-target/release/$($@PRODUCT)' | grep swift | awk '{print $3}' | xargs cp -Lv -t /build-target/lambda"
  
	# copy binary to stage
	cp $($@BUILD_DIR)/release/$($@PRODUCT) $($@BUILD_DIR)/lambda/bootstrap
  
  # copy app from stage to artifacts dir
	cp $($@STAGE)/* $($@ARTIFACTS_DIR)
