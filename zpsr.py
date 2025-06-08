import sys
import tokenize
import io
import token

class ZPSRLanguage:
    def __init__(self):
        self.char_mapping = {
            'й': 'q', 'ц': 'w', 'у': 'e', 'к': 'r', 'е': 't', 'н': 'y', 'г': 'u',
            'ш': 'i', 'щ': 'o', 'з': 'p', 'х': '[', 'ъ': ']', 'ф': 'a', 'ы': 's',
            'в': 'd', 'а': 'f', 'п': 'g', 'р': 'h', 'о': 'j', 'л': 'k', 'д': 'l',
            'ж': ';', 'э': "'", 'я': 'z', 'ч': 'x', 'с': 'c', 'м': 'v', 'и': 'b',
            'т': 'n', 'ь': 'm', 'б': ',', 'ю': '.', 'ё': '`', 'Ё': '~',
            'Й': 'Q', 'Ц': 'W', 'У': 'E', 'К': 'R', 'Е': 'T', 'Н': 'Y', 'Г': 'U',
            'Ш': 'I', 'Щ': 'O', 'З': 'P', 'Х': '{', 'Ъ': '}', 'Ф': 'A', 'Ы': 'S',
            'В': 'D', 'А': 'F', 'П': 'G', 'Р': 'H', 'О': 'J', 'Л': 'K', 'Д': 'L',
            'Ж': ':', 'Э': '"', 'Я': 'Z', 'Ч': 'X', 'С': 'C', 'М': 'V', 'И': 'B',
            'Т': 'N', 'Ь': 'M', 'Б': '<', 'Ю': '>',
        }

    def transliterate(self, text):
        return ''.join(self.char_mapping.get(ch, ch) for ch in text)

    def translate_code(self, code: str) -> str:
        result_tokens = []
        g = tokenize.generate_tokens(io.StringIO(code).readline)

        for toknum, tokval, _, _, _ in g:
            if toknum in (token.NAME, token.STRING, token.OP, token.ERRORTOKEN):
                tokval = self.transliterate(tokval)
            result_tokens.append((toknum, tokval))

        return tokenize.untokenize(result_tokens)

    def run_file(self, filepath):
        with open(filepath, 'r', encoding='utf-8') as f:
            code = f.read()
        py_code = self.translate_code(code)
        exec(py_code, globals())

def main():
    if len(sys.argv) != 2:
        print("Использование: zpsr файл.zpsr")
        sys.exit(1)

    filename = sys.argv[1]
    if not filename.endswith('.zpsr'):
        print("Ошибка: файл должен иметь расширение .zpsr")
        sys.exit(1)

    interpreter = ZPSRLanguage()
    interpreter.run_file(filename)

if __name__ == "__main__":
    main()
