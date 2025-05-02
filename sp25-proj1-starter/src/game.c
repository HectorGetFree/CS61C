#include "game.h"

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tgmath.h>

#include "snake_utils.h"

/* Helper function definitions */
static void set_board_at(game_t *game, unsigned int row, unsigned int col, char ch);
static bool is_tail(char c);
static bool is_head(char c);
static bool is_snake(char c);
static char body_to_tail(char c);
static char head_to_body(char c);
static unsigned int get_next_row(unsigned int cur_row, char c);
static unsigned int get_next_col(unsigned int cur_col, char c);
static void find_head(game_t *game, unsigned int snum);
static char next_square(game_t *game, unsigned int snum);
static void update_tail(game_t *game, unsigned int snum);
static void update_head(game_t *game, unsigned int snum);

/* Task 1 */
game_t *create_default_game() {
	// 先在堆中为game_t请求空间
	game_t* game = malloc(sizeof(game_t));
	if (game == NULL) {
		perror("malloc failed");
		return NULL;
	}
	// 然后为另一个结构指针分配空间
	game->snakes = malloc(sizeof(snake_t));
	if (game->snakes == NULL) {
		perror("malloc failed");
		return NULL;
	}
	// 设置默认值
	game->snakes->head_row = 2;
	game->snakes->head_col = 4;
	game->snakes->tail_row = 2; 
	game->snakes->tail_col = 2;
	game->snakes->live = true;
	game->num_rows = 18;
	game->num_snakes = 1;
	char board[18][22];
	for (int i = 0; i < 18; i++) {
		for (int j = 0; j < 22; j++) {
			

			// 上下边框
			if (i == 0 || i == 17) {
				board[i][j] = '#';
			} else {
				// 填充主体
				board[i][j] = ' ';
			}
			// 左右边框
			if (j == 0 || j == 19) {
				board[i][j] = '#';
			}
			// 设置字符串终结符号和换行符
			if (j == 20) {
				board[i][j] = '\n';
			}
			if (j == 21) {
				board[i][j] = '\0';
			}
		}
	}	
	// 设置snake和fruit的位置
	board[2][2] = 'd';
	board[2][3] = '>';
	board[2][4] = 'D';
	board[2][9] = '*';
	// 忽略的一点
	// 先给game -> board 分配空间，然后再复制
	game->board = malloc(sizeof(char *) * 20);
	if (game->board == NULL) {
		perror("malloc failed");
		return NULL;
	}

	for (int i = 0; i < 20; i++) {
		// 这里也要单独分配
		game->board[i] = malloc(20 * sizeof(char));
		if (game->board[i] == NULL) {
			perror("malloc failed");
			return NULL;
		}
		strcpy(game->board[i], board[i]);
	}

	// print-for-test

	// for (int i = 0; i < 18; i++) {
	// 	for (int j = 0; j < 22; j++) {
	// 			printf("%c", board[i][j]);
	// 	}
	// }
  	return game;
}

/* Task 2 */
void free_game(game_t *game) {
	// 先释放深层指针
    free(game->snakes);
	// 然后释放外层指针
    free(game);
}

/* Task 3 */
void print_board(game_t *game, FILE *fp) {
	if (fp == NULL) {
		perror("Counldn't open the file");
		return;
	}

	for (int i = 0; i < game->num_rows; i++) {
		fprintf(fp, "%s", game->board[i]);
	}
}

/*
  Saves the current game into filename. Does not modify the game object.
  (already implemented for you).
*/
void save_board(game_t *game, char *filename) {
  FILE *f = fopen(filename, "w");
  print_board(game, f);
  fclose(f);
}

/* Task 4.1 */

/*
  Helper function to get a character from the board
  (already implemented for you).
*/
char get_board_at(game_t *game, unsigned int row, unsigned int col) { return game->board[row][col]; }

/*
  Helper function to set a character on the board
  (already implemented for you).
*/
static void set_board_at(game_t *game, unsigned int row, unsigned int col, char ch) {
  game->board[row][col] = ch;
}

/*
  Returns true if c is part of the snake's tail.
  The snake consists of these characters: "wasd"
  Returns false otherwise.
*/
static bool is_tail(char c) {
	if (c == 'w' || c == 'a' || c == 's' || c == 'd') {
    	return true;
	}
	return false;
}

/*
  Returns true if c is part of the snake's head.
  The snake consists of these characters: "WASDx"
  Returns false otherwise.
*/
static bool is_head(char c) {
	if (c == 'W' || c == 'A' || c == 'S' || c == 'D' || c == 'x') {
    	return true;
	}
	return false;
}

/*
  Returns true if c is part of the snake.
  The snake consists of these characters: "wasd^<v>WASDx"
*/
static bool is_snake(char c) {
	if (c == 'w' || c == 'a' || c == 's' || c == 'd'
	|| c == 'W' || c == 'A' || c == 'S' || c == 'D' || c == 'x'
	|| c == '<' || c == '>' || c == '^' || c == 'v') {
    	return true;
	}
	return false;
}

/*
  Converts a character in the snake's body ("^<v>")
  to the matching character representing the snake's
  tail ("wasd").
*/
static char body_to_tail(char c) {
	if (c == '^') {
		return 'w';
	} else if (c == 'v') {
		return 's';
	} else if (c == '<') {
		return 'a';
	} else if (c == '>') {
		return 'd';
	}
	return '?';
}

/*
  Converts a character in the snake's head ("WASD")
  to the matching character representing the snake's
  body ("^<v>").
*/
static char head_to_body(char c) {
	if (c == 'W') {
		return '^';
	}
	if (c == 'A') {
		return '<';
	}
	if (c == 'S') {
		return 'v';
	}
	if (c == 'D') {
		return '>';
	}
	return '?';
}

/*
  Returns cur_row + 1 if c is 'v' or 's' or 'S'.
  Returns cur_row - 1 if c is '^' or 'w' or 'W'.
  Returns cur_row otherwise.
*/
static unsigned int get_next_row(unsigned int cur_row, char c) {
	if (c == 'v' || c == 's' || c == 'S') {
		return cur_row + 1;
	}
	if (c == '^' || c == 'w' || c == 'W') {
		return cur_row - 1;
	}
    return cur_row;
}

/*
  Returns cur_col + 1 if c is '>' or 'd' or 'D'.
  Returns cur_col - 1 if c is '<' or 'a' or 'A'.
  Returns cur_col otherwise.
*/
static unsigned int get_next_col(unsigned int cur_col, char c) {
	if (c == '>' || c == 'd' || c == 'D') {
		return cur_col + 1;
	} 
	if (c == '<' || c == 'a' || c == 'A') {
		return cur_col - 1;
	}
    return cur_col;
}

/*
  Task 4.2

  Helper function for update_game. Return the character in the cell the snake is moving into.

  This function should not modify anything.
*/
static char next_square(game_t *game, unsigned int snum) {
	snake_t *snakes = game->snakes;
	// 获取snum处的蛇
	snake_t snake = snakes[snum];
	unsigned int head_row = snake.head_row;
	unsigned int head_col = snake.head_col;
	char head = get_board_at(game, head_row, head_col);
	head_row = get_next_row(head_row, head);
	head_col = get_next_col(head_col, head);
	return get_board_at(game, head_row, head_col);
}

/*
  Task 4.3

  Helper function for update_game. Update the head...

  ...on the board: add a character where the snake is moving

  ...in the snake struct: update the row and col of the head

  Note that this function ignores food, walls, and snake bodies when moving the head.
*/
static void update_head(game_t *game, unsigned int snum) {
	snake_t *snakes = game->snakes;
	// 获取snum处的蛇
	// 注意这里要深拷贝
	// snake_t snake = snake[sum]是浅拷贝
	// C语言没有引用类型这个概念，所以不要搞混了
	snake_t *snake = &snakes[snum];
	// 获取头部坐标
	unsigned int head_row = snake->head_row;
	unsigned int head_col = snake->head_col;
	// 获取原来的头
	char head = get_board_at(game, head_row, head_col);
	// 将原来的头转化为身体
	char c = head_to_body(head);
	set_board_at(game, head_row, head_col, c);
	// 更新头部坐标
	head_row = get_next_row(head_row, head);
	head_col = get_next_col(head_col, head);
	// 更新蛇
	snake->head_row = head_row;
	snake->head_col = head_col;
	set_board_at(game, head_row, head_col, head);
}

/*
  Task 4.4

  Helper function for update_game. Update the tail...

  ...on the board: blank out the current tail, and change the new
  tail from a body character (^<v>) into a tail character (wasd)

  ...in the snake struct: update the row and col of the tail
*/
static void update_tail(game_t *game, unsigned int snum) {
	char **board = game->board;
	snake_t *snakes = game->snakes;
	// 获取snum处的蛇
	snake_t *snake = &snakes[snum];
	// 获取尾部坐标
	unsigned int tail_row = snake->tail_row;
	unsigned int tail_col = snake->tail_col;
	// 获取尾部字符
	char tail = get_board_at(game, tail_row, tail_col);
	// 删除尾部字符
	board[tail_row][tail_col] = ' ';
	// 更新坐标
	tail_row = get_next_row(tail_row, tail);
	tail_col = get_next_col(tail_col, tail);
	// 更新画板
	char c = get_board_at(game, tail_row, tail_col);
	char c1 = body_to_tail(c);
	set_board_at(game, tail_row,  tail_col, c1);
	// 更新蛇
	snake->tail_row = tail_row;
	snake->tail_col = tail_col;
}

/* Task 4.5 */
void update_game(game_t *game, int (*add_food)(game_t *game)) {
	// 获取基本数据
	char **board = game->board;
	snake_t *snakes = game->snakes;
	unsigned int n_snake = game->num_snakes;

	// 更新每一条蛇
	for (unsigned int i = 0; i < n_snake; i++) {
		// 获取一条蛇
		snake_t *snake = &snakes[i];
		// 获取他的下一个要前进的格子
		char c = next_square(game, i);
		// 如果遇到果实
		if (c == '*') {
			update_head(game, i);
			add_food(game);
		} else if (c == '#') {
		    // 如果遇到墙壁
			board[snake->head_row][snake->head_col] = 'x';
			snake->live = false;
		} else if (is_snake(c)) {
			// 如果碰到蛇
			board[snake->head_row][snake->head_col] = 'x';
			snake->live = false;
		} else {
			update_head(game, i);
			update_tail(game, i);
		}
	}
}

/* Task 5.1 */
char *read_line(FILE *fp) {
	// 先创建一个指针
	char *line = malloc(100 * sizeof(char));
	// 如果分配失败，返回空
	if (!line) return NULL;
	// 尝试读取，读取失败就释放内存，并返回空
	if (!fgets(line, 100, fp)) {
		free(line);
		return NULL;
	}
	// 计算新的字符串长度，别忘+1（'\0'）
	size_t len = strlen(line) + 1;
	// 重新分配，注意不要覆盖原来的指针
	char *tmp = realloc(line, len);
	// 分配失败就返回原来的空间指针
	if (tmp == NULL) {
		return line;
	}
	// 分配成功就返回新指针
	return tmp;
}

/* Task 5.2 */
game_t *load_board(FILE *fp) {
	// 为game分配空间
	game_t *game = malloc(sizeof(game_t));
	// 按要求设置相应变量
	game->num_snakes = 0;
	game->snakes = NULL;

	// 下面进行读取
	// 设置每行指针
	char *line = NULL;
	// 定义二维指针
	char **lines = NULL;
	// 设置计数变量用于动态扩容和重新分配
	size_t count = 0, capacity = 0;
	while ((line = read_line(fp)) != NULL) {
		if (count >= capacity) {
			// 要扩容了 --> 要读取下一行
			capacity = capacity ? capacity * 2 : 4;
			char **tmp = realloc(lines, capacity * sizeof(char *));
			if (!tmp) {
				perror("realloc failed");
				// 清理已分配行
				for (int i = 0; i < count; i++) {
					free(lines[i]);
				}
				return NULL;
			}
			lines = tmp;
		}
		lines[count++] = line;
	}
	// 为剩余变量赋值
	game->num_rows = (unsigned int)count;
	game->board = lines;
	return game;
}

/*
  Task 6.1

  Helper function for initialize_snakes.
  Given a snake struct with the tail row and col filled in,
  trace through the board to find the head row and col, and
  fill in the head row and col in the struct.
*/
static void find_head(game_t *game, unsigned int snum) {
	// 获取蛇
	snake_t *snakes = game->snakes;
	// 获取这条蛇
	snake_t *snake = &snakes[snum];
	// 获取坐标 -- 从尾部开始
	unsigned int row = snake->tail_row;
	unsigned int col = snake->tail_col;
	char c = get_board_at(game, row, col);
	// 循环抵达蛇头
	while (!is_head(c)) {
		row = get_next_row(row, c);
		col = get_next_col(col ,c);
		c = get_board_at(game, row, col);
	}
	snake->head_row = row;
	snake->head_col = col;
}

/* Task 6.2 */
game_t *initialize_snakes(game_t *game) {
    char **board = game->board;
    snake_t *snakes = NULL;
	// 数组容量
	unsigned int capacity = 4;
	// 计数
	unsigned int count = 0;
	// 第一次分配空间
	snakes = malloc(sizeof(snake_t) * capacity);
	// 遍历得到信息
	for (unsigned int i = 0; i < game->num_rows; i++) {
		size_t len = strlen(board[i]);
		for (unsigned int j = 0; j < len; j++) {
			char c = get_board_at(game, i, j);
			if (is_tail(c)) {
				// 判断是否需要扩容
				if (count >= capacity) {
					capacity *= 2;
					snake_t *tmp = realloc(snakes, sizeof(snake_t) * capacity);
					if (!tmp) {
						free(snakes);
						return NULL;
					}
					snakes = tmp;
				}
				snake_t *snake = &snakes[count];
				snake->tail_row = i;
				snake->tail_col = j;
				game->snakes = snakes;
				find_head(game, count);
				snake->live = true;
				count++;
			}
		}
	}
	game->num_snakes = count;
    return game;
}


