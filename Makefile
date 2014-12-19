ANSIBLE=ansible-playbook -i hosts
E=tinyvz

touch.ai: ai.yml stoplist.${E} stopfiles.${E} syslog-ng.conf.${E} ai.sh
	${ANSIBLE} ai.yml
	touch touch.ai

clean:
	rm -f touch.*
