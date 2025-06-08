import sys
import os
import shutil
from zpsr import ZPSRLanguage

def main():
    if len(sys.argv) != 2:
        print("Использование: zpsr-build файл.zpsr")
        return

    zpsr_file = sys.argv[1]
    if not zpsr_file.endswith(".zpsr"):
        print("Файл должен иметь расширение .zpsr")
        return

    # Чтение и трансляция
    zpsr = ZPSRLanguage()
    with open(zpsr_file, 'r', encoding='utf-8') as f:
        source = f.read()
    py_code = zpsr.translate_code(source)

    temp_py = "__temp_zpsr__.py"
    with open(temp_py, 'w', encoding='utf-8') as f:
        f.write(py_code)

    # Компиляция
    os.system(f"pyinstaller --onefile --noconsole {temp_py}")

    # Переименование
    exe_name = zpsr_file.replace(".zpsr", ".exe")
    shutil.move(f"dist/{temp_py.replace('.py', '.exe')}", exe_name)

    # Очистка
    shutil.rmtree("build")
    shutil.rmtree("dist")
    os.remove(temp_py)
    os.remove(f"{temp_py.replace('.py', '.spec')}")

    print(f"Компиляция завершена: {exe_name}")

if __name__ == "__main__":
    main()
