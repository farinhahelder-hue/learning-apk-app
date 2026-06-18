import sys

with open('lib/utils/app_theme.dart', 'r') as f:
    content = f.read()

content = content.replace("cardTheme: CardTheme(", "cardTheme: CardThemeData(")

with open('lib/utils/app_theme.dart', 'w') as f:
    f.write(content)
