EXERCISES += othello
CLEAN_FILES += othello

othello: othello_EOF.c
	$(CC) -o $@ $<

.PHONY: submit give

submit give: othello.s
	give cs1521 ass1_othello othello.s

.PHONY: test autotest

test autotest: othello.s
	1521 autotest othello othello.s
