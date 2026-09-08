import locale

locale.setlocale(locale.LC_ALL, '')
words = ['zebra', 'Ähre', 'apple', 'Banana']
print(sorted(words, key=locale.strxfrm))