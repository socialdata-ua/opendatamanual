
### Регулярні вирази (Regular Expressions)

Очищення даних в текстовому файлі виконується низкою операцій пошуку-заміни.
Роблячи таку роботу вручну,
ми знаходимо ті записи, формат яких не відповідає бажаному
і переписуємо їх *правильно*.
Наприклад, знаходимо назву місяця і міняємо відповідний запис на його аналог у форматі РРРР-ММ-ДД. 
Якщо даних багато, ручне виконання таких замін дуже непродуктивне.
Але простий пошук-заміна, типу того, що доступний за натиском CTRL+H у Word,
малопомічний для таких операцій.

Тому для них використовується мова *регулярних виразів*
(Regular Expressions, часто скорочуване до regexp).

Регулярні вирази виглядають страшно, але насправді вони досить прості.
Більшість символів означають самі себе.
Символи-шаблони та символи-операнди,
а це  `. ^ $ * + ? { } [ ] \ | ( )`
дозволяють задавати правила — які символи і скільки разів зустрінуті відповідатимуть шаблону.
Ескейп-символ `\` повертає символам-шаблонам і символам-операндам буквальне значення,
натомість в поєднанні з деякими літерами позначає класи символів.

Кожен символ-шаблон може символізувати певну множину символів.
Кількість входжень символів, що відповідають шаблону, задається множником,
розташованим після шаблона.
Символи можна групувати за допомогою дужок
і потім звертатися до значення, що співпало з шаблоном у дужках.

Оскільки кількіcть дужок-зі-запам'ятовуванням обмежена дев'ятьма,
існують дужки, що лише групують символи.

Простіше зрозуміти цю машинерію в дії.
Звернімося до щойно наведеного прикладу з форматом дати:

було                  стало        regexp пошук / коментар                          regex заміна
--------------------  ----------   ----------------------------------------------  ----------------------
24 серпня 1991 року   1991-08-24   `(\d{1,2})\s+сер.*?\s+(\d{4})\s+р\.?(?:оку)?`   `$2-08-$1`
13 сер 2013 р.        2013-08-13   див. вище                                        див. вище  
3 серпня 1795         1795-08-3    тут вираз дав не зовсім те, що хотілося        
0 середа 0000 р.оку   0000-08-0    вираз реально недосконалий, це він вибере теж

Придивімося до виразу уважніше.

`\d` це шаблон для будь-якої цифри.
У фігурних дужках після нього — кількість цифр: одна чи дві.
Дужки довкола них означають, що ми запам'ятаємо, що саме співпало з шаблоном, і це буде змінна `$1`.

`\s` означає будь-який пробіл, `+` після нього, що цих пробілів може бути і більше одного.
`сер` — початок слова «серпня», до якого це слово може скорочуватися.
`.*?` — крапка це шаблон для будь-якого символа,
зірочка означає будь-яку кількість (від нуля до нескінченності) таких символів,
а знак питання змушує обрати найкоротшу послідовність з можливих.
Чому тоді не обрано 0 символів? Бо далі йде наступний шаблон, `\s+`, з яким ми вже стикалися,
і `.*?` якраз годиться збігтися з усіма символами перед ним.

`(\d{4})`  —  рівно чотири цифри, які ми теж запам'ятаємо, це буде `$2`.
Далі, після знайомого одного чи більше пробілів, іде літера «р»
і (можливо) крапка. Це крапка, а не шаблон будь-якого символа, бо перед нею — ескейп-символ,
і вона одна або її нема, бо множником стоїть знак питання: `\.?`

Конструкція `(?:оку)?` означає, що далі можуть один раз бути, а можуть і не бути літери «оку»,
саме в такій послідовності. Якби ми написали `(оку)?`, це означало б те саме,
і «оку» або відсутність символів ставали би значенням змінної `$3`, але,
оскільки після відкривної дужки стоять знак питання і двокрапка,
жодної змінної тут не утворюється.

`$2-08-$1` означає, що треба написати вміст змінної `$2` (це у нас рік),
дефіс, цифри «0» і «8», знов дефіс і вміст змінної `$1` (це у нас день).

Як видно з прикладу, в регулярних виразах нема нічого надто неприступного для розуміння.
Щоправда, справу ускладнює те, що
реалізація регулярних виразів у різних мовах програмування і редакторах дещо відрізняється.
Але принципи їх побудови лишаються дуже подібними.
З певною натяжкою, до регулярних виразів можна віднести також *патерни Lua*.

: Часткове порівняння діалектів мови регулярних виразів

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
метасимвол   значення символа                                                                                                                                                                          «старий»\                                      POSIX                                 Perl                                                                Python                       Lua pattern
                                                                                                                                                                                                       regex                                                                                                                                                                                 
------------ ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- ---------------------------------------------- ------------------------------------- ------------------------------------------------------------------- ---------------------------- ------------------------------------------------------------------------------------------------------------------------------------------------------------
`\`          повертає звичайне значення метасимволам                                                                                                                                                   ✓                                              ✓                                     ✓                                                                   ✓                            %

`.`          крапка означає будь-який символ                                                                                                                                                           ✓                                              …*інколи* крім символа нового рядка   …крім символа нового рядка, а в \[\] завжди означає просто крапку   …крім символа нового рядка   ✓

`[ ]`        будь-який символ з наведених у квадратових дужках, наприклад \[xyz\] вибирає x, y, або z                                                                                                  ✓                                              \                                     ✓                                                                   \                            ✓
                                                                                                                                                                                                                                                                                                                                                                                             

`[^ ]`       будь-який символ **крім** наведених у квадратових дужках, наприклад \[\^xyz\] вибирає a, 6, або №, але не x, y, або z                                                                     ✓                                              \                                     ✓                                                                   \                            ✓
                                                                                                                                                                                                                                                                                                                                                                                             

`^`          позначає початок рядка                                                                                                                                                                    ✓\                                             ✓                                     ✓                                                                   \                            початок рядка тільки на початку виразу, інакше звичайний символ
                                                                                                                                                                                                       (або цілий рядок *у багаторядковому режимі*)                                                                                                                                          

`$`          позначає кінець рядка                                                                                                                                                                     ✓\                                             ✓                                     ✓                                                                   \                            кінець рядка тільки наприкінці виразу, інакше звичайний символ**````**
                                                                                                                                                                                                       (або цілий рядок *у багаторядковому режимі*)                                                                                                                                          

`()`         дужки позначають підвираз, результат якого може бути викликаний далі — як у виразі пошуку, так і у виразі заміни                                                                          ✓                                              ✓                                     ✓                                                                   \                            ✓\
                                                                                                                                                                                                                                                                                                                                                                                             Порожні дужки повертають число, що дорівнює позиції в рядку, наприклад ()ер() з рядком «волонтер» дасть значення 7 і 9, а з рядком «корупціонер» — 10 і 12

`\`*n*       де *n* — цифра від 1 до 9, викликає значення видповідних підвиразів, номери — в порядку появи у виразі, тобто (\[бм\]а)\\1\* вибере «мама», «баба», «ма», «ба», але не «бама» чи «маба»   ✓                                              ✓                                     \$*n* — \$1, \$2                                                    \                            %*n*
                                                                                                                                                                                                                                                                                                                                                                                             

`*`          будь-яка кількість входжень попереднього шаблона, наприклад ні\* вибиратиме н, ні, ніі, ніііііііііі, а \[так\]\* вибиратиме і «так» і «кат» і навіть «атака».                             ✓                                              ✓                                     ✓                                                                   ✓                            ✓

`\s`         будь-який пробіл                                                                                                                                                                          нема\                                          \                                     \                                                                   \                            %s
                                                                                                                                                                                                                                                                                                                                                                                             

`\w`         будь-яка літера,                                                                                                                                                                          нема\                                          \                                     \                                                                   \                            %a
                                                                                                                                                                                                                                                                                                                                                                                             

`\d`         будь-яка цифра, те саме що \[0-9\]                                                                                                                                                        нема\                                          \                                     \                                                                   \                            %d
                                                                                                                                                                                                                                                                                                                                                                                             
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Як видно з таблиці, різні реалізації регулярних виразів відрізняються достатнім чином,
щоби перш ніж починати використовувати інструмент з «підтримкою регулярних виразів»,
поцікавитися можливостями і обмеженнями конкретної реалізації.
Крім того, свої регулярні вирази на фазі виписування варто тестувати, 
для чого існують спеціальні сервіси:

[regexr.com](http://regexr.com)
:   Один з онлайн-сервісів для тестування регулярних виразів у реальному часі.
    Підсвітлює синтаксис, дає спливні підказки (англійською).
    Оскільки використовує браузер, працює зі стандартом регулярних виразів JavaScript.

[regex101.com](http://regex101.com)
:   Онлайн-сервіс для тестування регулярних виразів.
    Не підсвітлює синатксис, зате підтримує три діалекти regexp — 
    вбудовані в php, javascript і python.
