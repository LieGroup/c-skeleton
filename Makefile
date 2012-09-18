# -Wextra开启-Wall未包括的编译警告
CFLAGS=-g -O2 -Wall -Wextra -Isrc -rdynamic -DNDEBUG $(OPTFLAGS)
# -ldl 连接libdl.a。这个库里包含了dlopen, dlsym等函数。
LIBS=-ldl $(OPTLIBS)
# ?=表示该变量仅在用户未定义时定义
PREFIX?=/usr/local

SOURCES=$(wildcard src/**/*.c src/*.c)
#把SOURCES中的.c文件替换为.o,并以此定义OBJECTS变量
OBJECTS=$(patsubst %.c,%.o,$(SOURCES))

TEST_SRC=$(wildcard tests/*_tests.c)
TESTS=$(patsubst %.c,%,$(TEST_SRC))

TARGET=build/liblcthw.a
SO_TARGET=$(patsubst %.a,%.so,$(TARGET))

# The Target Build
all: $(TARGET) $(SO_TARGET) tests

# 定义新的target及选项
dev:CFLAGS=-g -Wall -Isrc -Wall -Wextra $(OPTFLAGS)
dev:all

$(TARGET): CFLAGS+= -fPIC
$(TARGET): build $(OBJECTS)
# 创建library archives. $@代表$(TARGET)
	ar rcs $@ $(OBJECTS)
	ranlib $@

$(SO_TARGET): $(TARGET) $(OBJECTS)
	$(CC) -shared -o $@ $(OBJECTS)

build:
	@mkdir -p build
	@mkdir -p bin
# The Unit Tests
# .PHOY表明tests是target，而不是指磁盘上的文件夹
.PHONY: tests
tests: $(TESTS)
# 定义多目标规则，展开后等同于将$TESTS_SRC中的每个.c编译链接
# 因为TESTS文件依赖于静态链接库，静态库必须放在-o之后，否则会找不到静态库函数
$(TESTS): %: %.c
	$(CC) $(CFLAGS) $< -o $@ $(TARGET) 
	sh ./tests/runtests.sh
valgrind:
	VALGRIND="valgrind --log-file=/tmp/valgrind-%p.log" $(MAKE)
# The Cleaner
clean:
	rm -rf build $(OBJECTS) $(TESTS)
	rm -f tests/tests.log
	find . -name "*.gc*" -exec rm {} \;
	rm -rf 'find . -name "*.dSYM" -print'

# The Install
install: all
	install -d $(DESTDIR)/$(PREFIX)/lib/
	install $(TARGET) $(DESTDIR)/$(PREFIX)/lib/

# The Checker is to dig out any attempts to use the "bad" functions in C. Namely the string functions and other "unprotected buffer" functions. 
BADFUNCS='[^_.>a-zA-Z0-9](str(n?cpy|n?cat|xfrm|n?dup|str|pbrk|tok|_)|stpn?cpy|a?sn?printf|byte_)'
check:
	@echo Files with potentially dangerous functions.
	#The || true is to prevent make from thinking that egrep not finding things is a failure.
	@egrep $(BADFUNCS) $(SOURCES) || true
