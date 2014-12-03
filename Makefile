ANSIBLE=ansible-playbook -i hosts
E=tinyvz


logtail: logtail-v3.21.c
	gcc -D_OS_UNIX -o $@ $?

all: touch.ai logtail

touch.ai: ai.yml stoplist.${E} stopfiles.${E} syslog-ng.conf.${E} ai.sh
	${ANSIBLE} ai.yml
	touch touch.ai

clean:
	rm -f touch.*
	rm -f logtail
