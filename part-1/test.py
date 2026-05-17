import os
import subprocess
import random
import re
import sys


def mat_mul(A, B, N):
    """Умножение матриц на чистом Python."""
    C = [0] * (N * N)
    for i in range(N):
        for j in range(N):
            for k in range(N):
                C[i * N + j] += A[i * N + k] * B[k * N + j]
    return C


def build_assignments(A, B, N):
    """Создает строку с инструкциями присваивания для Promela."""
    lines = []
    for i in range(N * N):
        lines.append(f"A[{i}]={A[i]};")
    lines.append("\n    ")
    for i in range(N * N):
        lines.append(f"B[{i}]={B[i]};")
    return "    " + " ".join(lines)


def run_test(N, A, B, test_name):
    expected_C = mat_mul(A, B, N)

    # Читаем оригинальный исходник
    with open("main.pml", "r", encoding="utf-8") as f:
        code = f.read()

    # Меняем #define N
    code = re.sub(r"#define N \d+", f"#define N {N}", code)

    # Ищем блок инициализации данных с помощью регулярных выражений
    # Заменяем всё между комментарием загрузки и запуском процессов
    init_pattern = r"(// Тестовые данные).*?(?=// Ожидаемый результат)"

    assignments = build_assignments(A, B, N)
    replacement = r"\1\n" + assignments + "\n\n    "

    code = re.sub(init_pattern, replacement, code, flags=re.DOTALL)

    # Временно сохраняем сгенерированный код
    tmp_filename = "main.pml.tmp"
    with open(tmp_filename, "w", encoding="utf-8") as f:
        f.write(code)

    # Запускаем Spin
    result = subprocess.run(["spin", tmp_filename], capture_output=True, text=True)
    out = result.stdout

    # Парсим вывод
    if "Result Matrix C:" not in out:
        print(
            f"[{test_name}] FAILED: Не удалось найти вывод матрицы (Result Matrix C:). Вывод Spin:\n{out}"
        )
        return False

    # Извлекаем числа из строк матрицы
    lines = out.split("Result Matrix C:")[1].strip().split("\n")
    actual_C = []

    try:
        # Считываем ровно N строк матрицы
        for i in range(N):
            line = lines[i].strip()
            # Ищем все целые (даже отрицательные) числа в строке
            nums = re.findall(r"-?\d+", line)
            actual_C.extend([int(x) for x in nums])

        print(f"[{test_name}]")

        def print_mat(name, M):
            print(f"  {name}:")
            for idx in range(N):
                print("    " + str(M[idx * N : (idx + 1) * N]))

        print_mat("Input A", A)
        print_mat("Input B", B)
        print_mat("Expected C", expected_C)
        print_mat("Actual C", actual_C)

        if actual_C == expected_C:
            print("  -> STATUS: PASSED\n")
            return True
        else:
            print("  -> STATUS: FAILED\n")
            return False
    except Exception as e:
        print(f"[{test_name}] FAILED: Ошибка парсинга вывода - {e}")
        return False


def main():
    if not os.path.exists("main.pml"):
        print("Ошибка: main.pml не найден в текущей директории.")
        sys.exit(1)

    print("Запуск автоматических тестов...")

    all_passed = True
    tests_count = 0

    for N in [2, 3, 4]:
        print(f"\n--- Тестирование матриц размера N={N} ---")

        # 1. Тест с нулевыми матрицами
        A = [0] * (N * N)
        B = [0] * (N * N)
        all_passed &= run_test(N, A, B, f"N={N}, Нулевая матрица")
        tests_count += 1

        # 2. Тест с единичными матрицами
        A = [1] * (N * N)
        B = [1] * (N * N)
        all_passed &= run_test(N, A, B, f"N={N}, Матрица единиц")
        tests_count += 1

        # 3. 5 случайных матриц
        for i in range(5):
            # Генерируем небольшие случайные числа (чтобы не было переполнения, хотя в ints оно редкость)
            A = [random.randint(-10, 10) for _ in range(N * N)]
            B = [random.randint(-10, 10) for _ in range(N * N)]
            all_passed &= run_test(N, A, B, f"N={N}, Случайные числа #{i+1}")
            tests_count += 1

    print(
        f"\n=== ИТОГ: {'ВСЕ ТЕСТЫ ПРОЙДЕНЫ' if all_passed else 'ЕСТЬ ОШИБКИ'} ({tests_count} тестов) ==="
    )

    # Удаляем временный файл
    if os.path.exists("main.pml.tmp"):
        os.remove("main.pml.tmp")

    if not all_passed:
        sys.exit(1)


if __name__ == "__main__":
    main()
