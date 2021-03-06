﻿
#Область Константы

Перем кВидыСимволов;

Процедура Инициализировать()
	Перем Алфавит, Номер;
	кВидыСимволов = Новый Соответствие;
	Алфавит = (
		"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_=+-*/<>%!?" +
		"абвгдеёжзийклмнопрстуфхцчшщъыьэюяАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ"
	);
	Для Номер = 1 По СтрДлина(Алфавит) Цикл
		кВидыСимволов[Сред(Алфавит, Номер, 1)] = "Буква"
	КонецЦикла;
	Для Номер = 0 По 9 Цикл
		кВидыСимволов[Строка(Номер)] = "Цифра"
	КонецЦикла;
КонецПроцедуры // Инициализировать()

#КонецОбласти // Константы

#Область Парсер

Функция Парсер(Знач Исходник) Экспорт
	Возврат Новый Структура(
		"Исходник,"
		"Позиция,"
		"Символ,"
		"Окружение",
		Исходник, 1, Сред(Исходник, 1, 1)
	);
КонецФункции // Парсер()

Функция ПрочитатьСимвол(Знач Исходник, Позиция)
	Позиция = Позиция + 1;
	Возврат Сред(Исходник, Позиция, 1);
КонецФункции // ПрочитатьСимвол()

Процедура Соседний(Знач Парсер, Токен, Литерал)
	Перем Исходник, Позиция, Символ, Начало;
	Исходник = Парсер.Исходник;
	Позиция = Парсер.Позиция;
	Символ = Парсер.Символ;
	Пока ПустаяСтрока(Символ) И Символ <> "" Цикл
		Символ = ПрочитатьСимвол(Исходник, Позиция);
	КонецЦикла;
	Токен = кВидыСимволов[Символ];
	Если Токен = "Буква" Тогда
		Начало = Позиция;
		Символ = ПрочитатьСимвол(Исходник, Позиция);
		Пока кВидыСимволов[Символ] <> Неопределено Цикл
			Символ = ПрочитатьСимвол(Исходник, Позиция);
		КонецЦикла;
		Литерал = Сред(Парсер.Исходник, Начало, Позиция - Начало);
		Токен = "Объект";
	ИначеЕсли Токен = "Цифра" Тогда
		Начало = Позиция;
		Символ = ПрочитатьСимвол(Исходник, Позиция);
		Пока кВидыСимволов[Символ] = "Цифра" Цикл
			Символ = ПрочитатьСимвол(Исходник, Позиция);
		КонецЦикла;
		Если Символ = "." Тогда
			Символ = ПрочитатьСимвол(Исходник, Позиция);
			Пока кВидыСимволов[Символ] = "Цифра" Цикл
				Символ = ПрочитатьСимвол(Исходник, Позиция);
			КонецЦикла;
		КонецЕсли;
		Литерал = Сред(Парсер.Исходник, Начало, Позиция - Начало);
		Токен = "Число";
	ИначеЕсли Символ = """" Тогда
		Начало = Позиция + 1;
		Символ = ПрочитатьСимвол(Исходник, Позиция);
		Пока Символ <> """" И Символ <> "" Цикл
			Символ = ПрочитатьСимвол(Исходник, Позиция);
		КонецЦикла;
		Литерал = Сред(Парсер.Исходник, Начало, Позиция - Начало);
		Токен = "Строка";
		Символ = ПрочитатьСимвол(Исходник, Позиция);
	ИначеЕсли Символ = "(" Или Символ = ")" Или Символ = "" Тогда
		Токен = Символ;
		Символ = ПрочитатьСимвол(Исходник, Позиция);
	Иначе
		ВызватьИсключение СтрШаблон("Неизвестный символ %1", Символ);
	КонецЕсли;
	Парсер.Позиция = Позиция;
	Парсер.Символ = Символ;
КонецПроцедуры // Соседний()

Функция Узел(Знач Имя, Знач Значение, Знач Соседний)
	Возврат Новый Структура("Имя, Значение, Соседний", Имя, Значение, Соседний);
КонецФункции // Узел()

Функция ГлавныйУзел(Знач Имя, Знач Дочерний, Знач Соседний)
	Возврат Новый Структура("Имя, Дочерний, Соседний", Имя, Дочерний, Соседний);
КонецФункции // ГлавныйУзел()

Функция Разобрать(Знач Парсер, Уровень = 0) Экспорт
	Перем Токен, Литерал;
	Соседний(Парсер, Токен, Литерал);
	Если Токен = "(" Тогда
		Уровень = Уровень + 1;
		Возврат ГлавныйУзел("Список", Разобрать(Парсер, Уровень), Разобрать(Парсер, Уровень));
	ИначеЕсли Токен = ")" Тогда
		Если Уровень = 0 Тогда
			ВызватьИсключение "Неожиданный символ `)`";
		КонецЕсли;
		Уровень = Уровень - 1;
	ИначеЕсли Токен = "" Тогда
		Если Уровень > 0 Тогда
			ВызватьИсключение "Ожидается `)`";
		КонецЕсли;
	Иначе
		Возврат Узел(Токен, Литерал, Разобрать(Парсер, Уровень))
	КонецЕсли;
	Возврат Неопределено;
КонецФункции // Разобрать()

#КонецОбласти // Парсер

#Область Окружение

Процедура ОткрытьОкружение(Окружение) Экспорт
	Окружение = Новый Структура("ВнешнееОкружение, Элементы", Окружение, Новый Соответствие);
КонецПроцедуры // ОткрытьОкружение()

Процедура ЗакрытьОкружение(Окружение) Экспорт
	Окружение = Окружение.ВнешнееОкружение;
КонецПроцедуры // ЗакрытьОкружение()

Функция ЭлементОкружения(Знач Окружение, Знач ИмяЭлемента) Экспорт
	Перем Элемент;
	Элемент = Окружение.Элементы[ИмяЭлемента];
	Пока Элемент = Неопределено И Окружение.ВнешнееОкружение <> Неопределено Цикл
		Окружение = Окружение.ВнешнееОкружение;
		Элемент = Окружение.Элементы[ИмяЭлемента];
	КонецЦикла;
	Если Элемент = Неопределено Тогда
		ВызватьИсключение СтрШаблон("Неизвестный Узел %1", ИмяЭлемента);
	КонецЕсли;
	Возврат Элемент;
КонецФункции // ЭлементОкружения()

#КонецОбласти // Окружение

#Область Интерпретатор

Функция Сумма(Знач Окружение, Знач Аргумент)
	Перем Значение;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Значение = Интерпретировать(Окружение, Аргумент);
	Аргумент = Аргумент.Соседний;
	Пока Аргумент <> Неопределено Цикл
		Значение = Значение + Интерпретировать(Окружение, Аргумент);
		Аргумент = Аргумент.Соседний;
	КонецЦикла;
	Возврат Значение;
КонецФункции // Сумма()

Функция Разность(Знач Окружение, Знач Аргумент)
	Перем Значение;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Значение = Интерпретировать(Окружение, Аргумент);
	Аргумент = Аргумент.Соседний;
	Если Аргумент = Неопределено Тогда
		Возврат -Значение;
	КонецЕсли;
	Пока Аргумент <> Неопределено Цикл
		Значение = Значение - Интерпретировать(Окружение, Аргумент);
		Аргумент = Аргумент.Соседний;
	КонецЦикла;
	Возврат Значение;
КонецФункции // Разность()

Функция Произведение(Знач Окружение, Знач Аргумент)
	Перем Значение;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Значение = Интерпретировать(Окружение, Аргумент);
	Аргумент = Аргумент.Соседний;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Пока Аргумент <> Неопределено Цикл
		Значение = Значение * Интерпретировать(Окружение, Аргумент);
		Аргумент = Аргумент.Соседний;
	КонецЦикла;
	Возврат Значение;
КонецФункции // Произведение()

Функция Частное(Знач Окружение, Знач Аргумент)
	Перем Значение;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Значение = Интерпретировать(Окружение, Аргумент);
	Аргумент = Аргумент.Соседний;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Пока Аргумент <> Неопределено Цикл
		Значение = Значение / Интерпретировать(Окружение, Аргумент);
		Аргумент = Аргумент.Соседний;
	КонецЦикла;
	Возврат Значение;
КонецФункции // Частное()

Функция Остаток(Знач Окружение, Знач Аргумент)
	Перем Значение;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Значение = Интерпретировать(Окружение, Аргумент);
	Аргумент = Аргумент.Соседний;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Пока Аргумент <> Неопределено Цикл
		Значение = Значение % Интерпретировать(Окружение, Аргумент);
		Аргумент = Аргумент.Соседний;
	КонецЦикла;
	Возврат Значение;
КонецФункции // Остаток()

Функция ЗначениеФункции(Знач Окружение, Знач СоставнаяФункция, Знач Аргумент)
	Перем Значение;
	ОткрытьОкружение(Окружение);
	Параметр = СоставнаяФункция.Значение;
	Пока Параметр <> Неопределено Цикл
		Если Аргумент = Неопределено Тогда
			ВызватьИсключение "Недостаточно фактических параметров";
		КонецЕсли;
		Окружение.Элементы[Параметр.Значение] = Интерпретировать(Окружение, Аргумент);
		Параметр = Параметр.Соседний;
		Аргумент = Аргумент.Соседний;
	КонецЦикла;
	Выражение = СоставнаяФункция.Соседний;
	Если Выражение = Неопределено Тогда
		ВызватьИсключение "Ожидается тело функции";
	КонецЕсли;
	Пока Выражение <> Неопределено Цикл
		Значение = Интерпретировать(Окружение, Выражение);
		Выражение = Выражение.Соседний;
	КонецЦикла;
	ЗакрытьОкружение(Окружение);
	Возврат Значение;
КонецФункции // ЗначениеФункции()

Функция ОпределениеФункции(Знач Окружение, Знач Список)
	Перем Имя, Параметры, Выражение;
	Имя = Список.Значение;
	Параметры = Список.Соседний;
	Выражение = Параметры.Соседний;
	Если Параметры.Имя = "Список" Тогда
		Параметры = Параметры.Дочерний;
		Если Не ПараметрыКорректны(Параметры) Тогда
			ВызватьИсключение "Ожидается имя параметра";
		КонецЕсли;
	ИначеЕсли Параметры.Имя <> "Объект" Тогда
		ВызватьИсключение "Ожидается имя параметра";
	Иначе
		Параметры = Узел("Объект", Параметры.Значение, Неопределено);
	КонецЕсли;
	Окружение.Элементы[Имя] = Узел("Лямбда", Параметры, Выражение);
	Возврат Неопределено;
КонецФункции // ОпределениеФункции()

Функция Лямбда(Знач Окружение, Знач Параметры)
	Перем Выражение;
	Выражение = Параметры.Соседний;
	Если Параметры.Имя = "Список" Тогда
		Параметры = Параметры.Значение;
		Если Не ПараметрыКорректны(Параметры) Тогда
			ВызватьИсключение "Ожидается имя параметра";
		КонецЕсли;
	ИначеЕсли Параметры.Имя <> "Объект" Тогда
		ВызватьИсключение "Ожидается имя параметра";
	Иначе
		Параметры = Узел("Объект", Параметры.Значение, Неопределено);
	КонецЕсли;
	Возврат Узел("Лямбда", Параметры, Выражение);
КонецФункции // Лямбда()

// вспомогательная функция
Функция ПараметрыКорректны(Параметры)
	Возврат Параметры = Неопределено Или Параметры.Имя = "Объект" И ПараметрыКорректны(Параметры.Соседний);
КонецФункции // ПараметрыКорректны()

Функция Пусть(Знач Окружение, Знач Список)
	Перем Имя, Значение;
	Имя = Список.Значение;
	Значение = Интерпретировать(Окружение, Список.Соседний);
	Окружение.Элементы[Имя] = Значение;
	Возврат Неопределено;
КонецФункции // Пусть()

Функция ЗначениеВыраженияЕсли(Знач Окружение, Знач Список)
	Перем СписокЕсли, СписокТогда, СписокИначе;
	СписокЕсли = Список;
	СписокТогда = Список.Соседний;
	СписокИначе = СписокТогда.Соседний;
	Возврат ?(
		Интерпретировать(Окружение, СписокЕсли),
			Интерпретировать(Окружение, СписокТогда),
			Интерпретировать(Окружение, СписокИначе)
	);
КонецФункции // ЗначениеВыраженияЕсли()

Функция ЗначениеВыраженияВыбор(Знач Окружение, Знач Список)
	Перем СписокКогда, СписокТогда;
	СписокКогда = Список;
	Если СписокКогда = Неопределено Тогда
		ВызватьИсключение "Ожидается условие";
	КонецЕсли;
	Пока СписокКогда <> Неопределено Цикл
		СписокТогда = СписокКогда.Соседний;
		Если СписокТогда = Неопределено Тогда
			ВызватьИсключение "Ожидается выражение";
		КонецЕсли;
		Если Интерпретировать(Окружение, СписокКогда) Тогда
			Возврат Интерпретировать(Окружение, СписокТогда);
		КонецЕсли;
		СписокКогда = СписокТогда.Соседний;
	КонецЦикла;
	ВызватьИсключение "Ни одно из условий не сработало!";
КонецФункции // ЗначениеВыраженияВыбор()

Функция Равно(Знач Окружение, Знач Аргумент)
	Перем Значение, Результат;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Значение = Интерпретировать(Окружение, Аргумент);
	Аргумент = Аргумент.Соседний;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Результат = Истина;
	Пока Аргумент <> Неопределено И Результат Цикл
		Результат = Результат И Значение = Интерпретировать(Окружение, Аргумент);
		Аргумент = Аргумент.Соседний;
	КонецЦикла;
	Возврат Результат;
КонецФункции // Равно()

Функция Больше(Знач Окружение, Знач Аргумент)
	Перем Значение1, Значение2;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Значение1 = Интерпретировать(Окружение, Аргумент);
	Аргумент = Аргумент.Соседний;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Результат = Истина;
	Пока Аргумент <> Неопределено И Результат Цикл
		Значение2 = Интерпретировать(Окружение, Аргумент);
		Результат = Результат И Значение1 > Значение2;
		Значение1 = Значение2;
		Аргумент = Аргумент.Соседний;
	КонецЦикла;
	Возврат Результат;
КонецФункции // Больше()

Функция Меньше(Знач Окружение, Знач Аргумент)
	Перем Значение1, Значение2;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Значение1 = Интерпретировать(Окружение, Аргумент);
	Аргумент = Аргумент.Соседний;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Результат = Истина;
	Пока Аргумент <> Неопределено И Результат Цикл
		Значение2 = Интерпретировать(Окружение, Аргумент);
		Результат = Результат И Значение1 < Значение2;
		Значение1 = Значение2;
		Аргумент = Аргумент.Соседний;
	КонецЦикла;
	Возврат Результат;
КонецФункции // Меньше()

Функция БольшеИлиРавно(Знач Окружение, Знач Аргумент)
	Перем Значение1, Значение2;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Значение1 = Интерпретировать(Окружение, Аргумент);
	Аргумент = Аргумент.Соседний;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Результат = Истина;
	Пока Аргумент <> Неопределено И Результат Цикл
		Значение2 = Интерпретировать(Окружение, Аргумент);
		Результат = Результат И Значение1 >= Значение2;
		Значение1 = Значение2;
		Аргумент = Аргумент.Соседний;
	КонецЦикла;
	Возврат Результат;
КонецФункции // БольшеИлиРавно()

Функция МеньшеИлиРавно(Знач Окружение, Знач Аргумент)
	Перем Значение1, Значение2;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Значение1 = Интерпретировать(Окружение, Аргумент);
	Аргумент = Аргумент.Соседний;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Результат = Истина;
	Пока Аргумент <> Неопределено И Результат Цикл
		Значение2 = Интерпретировать(Окружение, Аргумент);
		Результат = Результат И Значение1 <= Значение2;
		Значение1 = Значение2;
		Аргумент = Аргумент.Соседний;
	КонецЦикла;
	Возврат Результат;
КонецФункции // МеньшеИлиРавно()

Функция НеРавно(Знач Окружение, Знач Аргумент)
	Перем Значение1, Значение2;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Значение1 = Интерпретировать(Окружение, Аргумент);
	Аргумент = Аргумент.Соседний;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Результат = Истина;
	Пока Аргумент <> Неопределено И Результат Цикл
		Значение2 = Интерпретировать(Окружение, Аргумент);
		Результат = Результат И Значение1 <> Значение2;
		Значение1 = Значение2;
		Аргумент = Аргумент.Соседний;
	КонецЦикла;
	Возврат Результат;
КонецФункции // НеРавно()

Функция ЛогическоеИ(Знач Окружение, Знач Аргумент)
	Перем Значение;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Результат = Истина;
	Пока Аргумент <> Неопределено И Результат Цикл
		Значение = Интерпретировать(Окружение, Аргумент);
		Результат = Результат И Значение;
		Аргумент = Аргумент.Соседний;
	КонецЦикла;
	Возврат Результат;
КонецФункции // ЛогическоеИ()

Функция ЛогическоеИли(Знач Окружение, Знач Аргумент)
	Перем Значение;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Результат = Ложь;
	Пока Аргумент <> Неопределено И Не Результат Цикл
		Значение = Интерпретировать(Окружение, Аргумент);
		Результат = Результат Или Значение;
		Аргумент = Аргумент.Соседний;
	КонецЦикла;
	Возврат Результат;
КонецФункции // ЛогическоеИли()

Функция ЛогическоеНе(Знач Окружение, Знач Аргумент)
	Перем Значение;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Результат = Истина;
	Пока Аргумент <> Неопределено И Результат Цикл
		Значение = Интерпретировать(Окружение, Аргумент);
		Результат = Результат И Не Значение;
		Аргумент = Аргумент.Соседний;
	КонецЦикла;
	Возврат Результат;
КонецФункции // ЛогическоеНе()

Функция ВывестиСообщение(Знач Окружение, Знач Аргумент)
	Перем Значения;
	Если Аргумент = Неопределено Тогда
		ВызватьИсключение "Ожидается аргумент";
	КонецЕсли;
	Значения = Новый Массив;
	Пока Аргумент <> Неопределено Цикл
		Значения.Добавить(Интерпретировать(Окружение, Аргумент));
		Аргумент = Аргумент.Соседний;
	КонецЦикла;
	Сообщить(СтрСоединить(Значения, " "));
	Возврат Неопределено;
КонецФункции // ВывестиСообщение

Функция Интерпретировать(Знач Окружение, Знач Узел, Знач Применить = Ложь) Экспорт
	Перем Имя, Значение, Лямбда;
	Имя = Узел.Имя;
	//Сообщить("Имя: " + Имя);

	Если Имя = "Список" Тогда
		Значение = Узел.Дочерний;
	Иначе
		Значение = Узел.Значение;
	КонецЕсли;

	Если Имя = "Объект" Тогда
		//Сообщить(Значение);
		Если Значение = "Функция" Тогда
			Возврат ОпределениеФункции(Окружение, Узел.Соседний);
		ИначеЕсли Значение = "Пусть" Тогда
			Возврат Пусть(Окружение, Узел.Соседний);
		ИначеЕсли Значение = "Лямбда" Тогда
			Возврат Лямбда(Окружение, Узел.Соседний);
		ИначеЕсли Значение = "Список" Тогда
			Возврат Узел("Список", Узел.Соседний, Неопределено);
		ИначеЕсли Значение = "Пустой" Тогда
			Возврат Интерпретировать(Окружение, Узел.Соседний).Значение = Неопределено;
		ИначеЕсли Значение = "Морда" Тогда
			Список = Интерпретировать(Окружение, Узел.Соседний);
			Возврат Интерпретировать(Окружение, Список.Значение);
		ИначеЕсли Значение = "Хвост" Тогда
			Список = Интерпретировать(Окружение, Узел.Соседний);
			Возврат Узел("Список", Список.Значение.Соседний, Неопределено);
		ИначеЕсли Значение = "Если" Тогда
			Возврат ЗначениеВыраженияЕсли(Окружение, Узел.Соседний);
		ИначеЕсли Значение = "Выбор" Тогда
			Возврат ЗначениеВыраженияВыбор(Окружение, Узел.Соседний);
		ИначеЕсли Значение = "Сообщить" Тогда
			Возврат ВывестиСообщение(Окружение, Узел.Соседний);
		ИначеЕсли Значение = "+" Тогда
			Возврат Сумма(Окружение, Узел.Соседний);
		ИначеЕсли Значение = "-" Тогда
			Возврат Разность(Окружение, Узел.Соседний);
		ИначеЕсли Значение = "*" Тогда
			Возврат Произведение(Окружение, Узел.Соседний);
		ИначеЕсли Значение = "/" Тогда
			Возврат Частное(Окружение, Узел.Соседний);
		ИначеЕсли Значение = "%" Тогда
			Возврат Остаток(Окружение, Узел.Соседний);
		ИначеЕсли Значение = "=" Тогда
			Возврат Равно(Окружение, Узел.Соседний);
		ИначеЕсли Значение = ">" Тогда
			Возврат Больше(Окружение, Узел.Соседний);
		ИначеЕсли Значение = "<" Тогда
			Возврат Меньше(Окружение, Узел.Соседний);
		ИначеЕсли Значение = ">=" Тогда
			Возврат БольшеИлиРавно(Окружение, Узел.Соседний);
		ИначеЕсли Значение = "<=" Тогда
			Возврат МеньшеИлиРавно(Окружение, Узел.Соседний);
		ИначеЕсли Значение = "<>" Тогда
			Возврат НеРавно(Окружение, Узел.Соседний);
		ИначеЕсли Значение = "И" Тогда
			Возврат ЛогическоеИ(Окружение, Узел.Соседний);
		ИначеЕсли Значение = "Или" Тогда
			Возврат ЛогическоеИли(Окружение, Узел.Соседний);
		ИначеЕсли Значение = "Не" Тогда
			Возврат ЛогическоеНе(Окружение, Узел.Соседний);
		ИначеЕсли Значение = "Истина" Тогда
			Возврат Истина;
		ИначеЕсли Значение = "Ложь" Тогда
			Возврат Ложь;
		ИначеЕсли Значение = "Неопределено" Тогда
			Возврат Неопределено;
		Иначе
			ЭлементОкружения = ЭлементОкружения(Окружение, Узел.Значение);
			Если ТипЗнч(ЭлементОкружения) = Тип("Структура") Тогда
				Если ЭлементОкружения.Имя = "Лямбда" Тогда
					Если Применить Тогда
						Возврат ЗначениеФункции(Окружение, ЭлементОкружения, Узел.Соседний);
					Иначе
					    Возврат ЭлементОкружения;
					КонецЕсли;
				ИначеЕсли ЭлементОкружения.Имя = "Список" Тогда
					Возврат ЭлементОкружения;
				Иначе
					ВызватьИсключение "Неизвестный объект";
				КонецЕсли;
			Иначе
				Возврат ЭлементОкружения;
			КонецЕсли;
		КонецЕсли;
	ИначеЕсли Имя = "Число" Тогда
		Возврат Число(Значение);
	ИначеЕсли Имя = "Строка" Тогда
		Возврат Значение;
	ИначеЕсли Применить Тогда
		Лямбда = Интерпретировать(Окружение, Значение);
		Возврат ЗначениеФункции(Окружение, Лямбда, Узел.Соседний);
	Иначе // Список
		Возврат Интерпретировать(Окружение, Значение, Истина);
	КонецЕсли;
КонецФункции // Интерпретировать()

#КонецОбласти // Интерпретатор

Функция Пуск(Знач Исходник) Экспорт
	Перем Парсер, Список, Результат;
	Парсер = Парсер(Исходник);
	Список = Разобрать(Парсер);
	Результат = Новый Массив;
	ОткрытьОкружение(Парсер.Окружение);
	Пока Список <> Неопределено Цикл
		Значение = Интерпретировать(Парсер.Окружение, Список);
		Если Значение <> Неопределено Тогда
			Результат.Добавить(Значение);
		КонецЕсли;
		Список = Список.Соседний;
	КонецЦикла;
	ЗакрытьОкружение(Парсер.Окружение);
	Возврат СтрСоединить(Результат, Символы.ПС);
КонецФункции // Пуск()

Инициализировать();
