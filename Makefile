build:
	docker build -t "jos/jenkins" -f Dockerfile .

.PHONY:test
test:
	docker build -t "jos/jenkins-candidate" -f Dockerfile .
	sh test/run
