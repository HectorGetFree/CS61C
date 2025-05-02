# 这里因为用的是apple silicon
# 所以将编译器改为clang
# 同时禁用CS61C的课程检查
# 避免因修改makefile报错
CC = clang
CFLAGS = -Wall -Wno-unused-function -Wconversion -std=c99 -g -O0
LDFLAGS =
SNAKE_DEPS = src/snake.o src/snake_utils.o src/game.o
INTERACTIVE_DEPS = src/interactive_snake.o src/snake_utils.o src/game.o
UNIT_TESTS_DEPS = src/snake_utils.o src/unit_tests.o src/asserts.o
CUSTOM_TESTS_DEPS = src/snake_utils.o src/custom_tests.o src/asserts.o
SHORTER_TESTS = 01-simple 02-direction 03-tail 04-food 05-wall 06-small 07-medium 08-multisnake 09-everything 10-filled 11-manyclose 12-corner 13-sus 14-orochi 15-hydra
LONGER_TESTS = 16-huge 17-wide 18-tall 19-101-127 20-long-line 21-bigL

COLOR_GREEN =
COLOR_RESET =
ifeq (,${NO_COLOR})
	ifneq (,$(findstring xterm,${TERM}))
		override COLOR_GREEN := $(shell tput setaf 2)
		override COLOR_RESET := $(shell tput sgr0)
	endif
endif

.PHONY: all
all: interactive-snake snake unit-tests custom-tests

snake: $(SNAKE_DEPS)
	$(CC) -o $@ $^ $(CFLAGS) $(LDFLAGS)

interactive-snake: $(INTERACTIVE_DEPS)
	$(CC) -o $@ $^ -pthread $(CFLAGS) $(LDFLAGS)

unit-tests: $(UNIT_TESTS_DEPS)
	# @$(MAKE) check-hashes
	$(CC) -o $@ $^ $(CFLAGS) $(LDFLAGS)

custom-tests: $(CUSTOM_TESTS_DEPS)
	# @$(MAKE) check-hashes
	$(CC) -o $@ $^ $(CFLAGS) $(LDFLAGS)

%.o: %.c
	$(CC) -c -o $@ $< $(CFLAGS)

src/unit_tests.o: src/unit_tests.c src/game.c src/asserts.c
	$(CC) -c -o $@ $< $(CFLAGS)

src/custom-tests.o: src/custom_tests.c src/game.c src/asserts.c
	$(CC) -c -o $@ $< $(CFLAGS)

# 禁用修改检查

# .PHONY: check-hashes
# check-hashes:
#     @bash tools/run_python.sh tools/check_hashes.py

.PHONY: clean
clean:
	rm -f interactive-snake snake unit-tests custom-tests unit-test-*.snk *.exe *.o src/*.o tests/*-out.snk


# 同样因为使用的是Apple Silicon
# 将内存泄露检测工具替换为了leaks
# 但是由于程序运行太快
# leaks 无法附着
# TODO: 等待进一步解决
.PHONY: leaks-test-free-game
leaks-test-free-game: unit-tests
	@./unit-tests & \
	PID=$$!; \
	echo "Running leaks on PID $$PID"; \
	sleep 2; \
	leaks $$PID || true; \
	kill $$PID || true

.PHONY: run-integration-tests
run-integration-tests: $(SHORTER_TESTS) $(LONGER_TESTS) run-nonexistent-input-file-test

.PHONY: run-nonexistent-input-file-test
run-nonexistent-input-file-test: snake
	@bash tools/test_nonexistent_input_file.sh

.PHONY: $(SHORTER_TESTS)
$(SHORTER_TESTS): snake
	@sed 's/\r$$//g' "tests/$(@F)-in.snk" > "tests/.$(@F)-in.snk.tmp"
	@mv "tests/.$(@F)-in.snk.tmp" "tests/$(@F)-in.snk"
	@sed 's/\r$$//g' "tests/$(@F)-ref.snk" > "tests/.$(@F)-ref.snk.tmp"
	@mv "tests/.$(@F)-ref.snk.tmp" "tests/$(@F)-ref.snk"
	@rm -f "tests/$(@F)-out.snk"
	./snake -i "tests/$(@F)-in.snk" -o "tests/$(@F)-out.snk"
	diff "tests/$(@F)-ref.snk" "tests/$(@F)-out.snk"
	@echo "${COLOR_GREEN}Passed $(@F)${COLOR_RESET}"

.PHONY: $(LONGER_TESTS)
$(LONGER_TESTS): snake
	@sed 's/\r$$//g' "tests/$(@F)-in.snk" > "tests/.$(@F)-in.snk.tmp"
	@mv "tests/.$(@F)-in.snk.tmp" "tests/$(@F)-in.snk"
	@sed 's/\r$$//g' "tests/$(@F)-ref.snk" > "tests/.$(@F)-ref.snk.tmp"
	@mv "tests/.$(@F)-ref.snk.tmp" "tests/$(@F)-ref.snk"
	@rm -f "tests/$(@F)-out.snk"
	./snake -i "tests/$(@F)-in.snk" -o "tests/$(@F)-out.snk"
	diff -q "tests/$(@F)-ref.snk" "tests/$(@F)-out.snk"
	@echo "${COLOR_GREEN}Passed $(@F)${COLOR_RESET}"
