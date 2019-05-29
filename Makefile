package := $(shell basename `pwd`)

include .env

clean:
		@rm -rf dist
		@mkdir -p dist

build: clean
		@for dir in `ls handler`; do \
			GOOS=linux go build -o dist/handler/$$dir github.com/sunilsv/Test-Project-2013/handler/$$dir; \
		done
		
get:
		cd tf && terraform init
	
run:
		aws-sam-local local start-api

install:
		go get github.com/aws/aws-lambda-go/events
		go get github.com/aws/aws-lambda-go/lambda
		go get github.com/stretchr/testify/assert

install-dev:
		go get github.com/awslabs/aws-sam-local

test:
		go test ./... --cover

configure:
		aws s3api create-bucket \
			--bucket $(AWS_BUCKET_NAME) \
			--region $(AWS_REGION) \
			--create-bucket-configuration LocationConstraint=$(AWS_REGION)

package: build
		@aws cloudformation package \
			--template-file template.yml \
			--s3-bucket $(AWS_BUCKET_NAME) \
			--region $(AWS_REGION) \
			--output-template-file package.yml

deploy:
		mkdir -p target
		rm -f target/*
		GOOS=linux GOARCH=amd64 go build ${LDFLAGS} -v -o target/$(package)_linux_amd64
		zip -j target/$(package).zip target/$(package)_linux_amd64
		cd tf && terraform apply -auto-approve

describe:
		@aws cloudformation describe-stacks \
			--region $(AWS_REGION) \
			--stack-name $(AWS_STACK_NAME) \

outputs:
		@make describe | jq -r '.Stacks[0].Outputs'

url:
		@make describe | jq -r ".Stacks[0].Outputs[0].OutputValue" -j