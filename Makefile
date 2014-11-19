ANSIBLE=ansible-playbook -i hosts

all: touch.ai

touch.ai: ai.yml stoplist stopfiles ai.sh
	${ANSIBLE} ai.yml
	touch touch.ai

clean:
	rm -f touch.*
