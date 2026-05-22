// Размер квадратных матриц N*N
#define N 3
// Количество параллельных процессов
#define P 2

typedef Row {
	int elements[N];
};

// Одномерные массивы для хранения двумерных матриц N*N
int A[N * N];
int B[N * N];
int C[N * N];

// Флаг завершения всех вычислений (для верификации LTL)
bool done = false;

// Канал для передачи данных от рабочих процессов к нулевому.
// Передается: { номер строки, номер столбца, вычисленное значение }
chan row_computed = [N] of { byte, Row };

// Функция рабочего процесса (воркера)
proctype worker(byte id) {
// Процесс берет строки с шагом P, начиная со строки = id
	byte row = id;
	byte col,k;
	int sum;
	Row current;

// Цикл по строкам, закрепленным за данным процессом
	do
	:: row < N -> 
		col = 0;
// Цикл по столбцам матрицы B
		do
		:: col < N -> 
			sum = 0;
			k = 0;
// Вычисление скалярного произведения строки A и столбца B
			do
			:: k < N -> 
				sum = sum + A[row * N + k] * B[k * N + col];
				k = k + 1;
			:: k == N -> break;
			od;
			
// Если это нулевой процесс, он сразу пишет в итоговую матрицу
			if
			:: id == 0 -> 
				C[row * N + col] = sum;
// Остальные процессы отправляют результат через канал нулевому процессу
			:: id != 0 ->
				current.elements[col] = sum; 
				//row_computed!row,col,sum;
			fi;
			col = col + 1;
		:: col == N -> break;
		od;

		if 
		:: id != 0 ->
			row_computed!row,current;
		:: id == 0 -> skip;
		fi;

// Переход к следующей строке, закрепленной за этим процессом
		row = row + P;
	:: row >= N -> break;
	od;
	
// Только нулевой процесс занимается агрегацией и выводом
	if
	:: id == 0 -> 
		int i,j;
		int expected_rows = 0;
		i = 0;
// Подсчитываем, сколько элементов мы должны получить из канала (сколько элементов вычислили другие процессы)
		do
		:: i < N -> 
			if
			:: (i % P) != 0 -> expected_rows++;
			:: else -> skip;
			fi;
			i = i + 1;
		:: i == N -> break;
		od;
		
		int received = 0;
		byte r, c;
		Row receivedRow;
		c=0;
// Цикл ожидания и чтения вычисленных элементов из канала
		do
		:: received < expected_rows -> 
			row_computed?r,receivedRow;
// Запись полученного элемента в результирующую матрицу
			do
			:: c < N -> 
				C[r*N + c] = receivedRow.elements[c];
				c++;
			:: c == N -> break;
			od;

			//C[r * N + c] = val;
			//c++;
			received++;
		:: received == expected_rows -> break;
		od;
		
// Вывод итоговой матрицы C
		printf("Result Matrix C:\n");
		i = 0;
		do
		:: i < N -> 
			j = 0;
			printf("[");
			do
			:: j < N -> 
				if 
				:: j < N - 1 -> printf("%d,",C[i * N + j]);
				:: j == N - 1 -> printf("%d",C[i * N + j]);
				fi;
				j = j + 1;
			:: j == N -> break;
			od;
			printf("]\n");
			i = i + 1;
		:: i == N -> break;
		od;
		
// Устанавливаем флаг завершения работы
		done = true;
	:: id != 0 -> skip;
	fi;
}

init {
// Тестовые данные
	A[0] = 5;A[1] = 3;A[2] = 7;
	A[3] = 1;A[4] = 4;A[5] = 0;
	A[6] = 3;A[7] = 9;A[8] = 1;
	
	B[0] = 3;B[1] = 8;B[2] = 7;
	B[3] = 7;B[4] = 2;B[5] = 1;
	B[6] = 1;B[7] = 9;B[8] = 1;
// Ожидаемый результат
// [43,109,45]
// [31,16,11]
// [73,51,31]
	
// Атомарный запуск P рабочих процессов
	int proc_id = 0;
	atomic {
		do
		:: proc_id < P -> 
			run worker(proc_id);
			proc_id = proc_id + 1;
		:: proc_id == P -> break;
		od;
	}
}

// Свойство живости
ltl liveness { <> (done == true) }

// Свойство безопасности
ltl safety { [] (done -> (C[0] == 43 && C[1] == 109 && C[2] == 45 &&
	C[3] == 31 && C[4] == 16 && C[5] == 11 &&
	C[6] == 73 && C[7] == 51 && C[8] == 31)) }
