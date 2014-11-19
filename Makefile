ANSIBLE=ansible-playbook -i hosts

all: touch.ai

touch.%: %.yml
	${ANSIBLE} $?
	touch $@

clean:
	rm -f touch.*
