#Использовать JSON

Перем Консоль;
Перем ПарсерJSON;
Перем НачалоИтерации;
Перем НомерИтерации;
Перем Отладка;

Перем Состояние;
Перем Ответ;
Перем Корабли;
Перем КораблиПротивника;

/////////////////////////////////////////////////////
// Сценарий

Процедура ВыполнитьСценарий()
	
	// Если противник разряжен
	
	РасстояниеМеждуКораблямиПротивника = 0;
	Для Каждого Противник Из КораблиПротивника Цикл
		Для Каждого Противник2 Из КораблиПротивника Цикл
			РасстояниеМеждуКораблямиПротивника = РасстояниеМеждуКораблямиПротивника + 
				РасстояниеЧебышев(
					НовыйВектор(Противник["Position"]), 
					НовыйВектор(Противник2["Position"])
				);
		КонецЦикла;
	КонецЦикла;	

	РасстояниеМеждуКораблямиПротивника = РасстояниеМеждуКораблямиПротивника / КораблиПротивника.Количество();

	// Обработка движения кораблей

	ЦельПеремещенияИндекс = 0;

	Для Каждого Корабль Из Корабли Цикл

		// Выбор цели для перемещения

		ЦельПеремещения 	  = КораблиПротивника[ЦельПеремещенияИндекс];
		ЦельПеремещенияИндекс = (ЦельПеремещенияИндекс + 1) % КораблиПротивника.Количество();

		// Если группа не разяряженная используем АП иначе нет

		КомандаПеремещения = Неопределено;

		Если ПолучитьРазрешенныйВыстрел(Корабль, ЦельПеремещения) <> Неопределено
			И РасстояниеМеждуКораблямиПротивника < 20 Тогда
			КомандаПеремещения = Ускорение(Корабль, ПозицияКОтступлениюПоНачальнойПозиции(Корабль));
		Иначе				
			КомандаПеремещения = Ускорение(Корабль, ЦельПеремещения["Position"]);
		КонецЕсли;

		ДобавитьКоманду(КомандаПеремещения); 

	КонецЦикла;

	// Оработка стрельбы

	ЦельАтаки = ЦельАтаки();

	Для Каждого Корабль Из Корабли Цикл

		Выстрел = ПолучитьРазрешенныйВыстрел(Корабль, ЦельАтаки);
		
		Если Выстрел = Неопределено Тогда
			Для Каждого Враг Из КораблиПротивника Цикл
				Выстрел = ПолучитьРазрешенныйВыстрел(Корабль, Враг);
				Если Выстрел <> Неопределено Тогда
					Прервать;	
				КонецЕсли;
			КонецЦикла;	
		КонецЕсли;
		
		ДобавитьКоманду(Выстрел);

	КонецЦикла;
	
	//Отладка.Добавить(ПарсерJSON.ЗаписатьJSON(Ответ));
	
КонецПроцедуры

/////////////////////////////////////////////////////
// Процедуры и функции обработки сценария

Функция ПолучитьРазрешенныйВыстрел(Корабль, Враг, Знач Орудие = Неопределено)

	Если Орудие = Неопределено Тогда
		Орудие = ОсновноеОрудиеКорабля(Корабль);
	КонецЕсли;

	ПоправкаНаСближение = 1;

	РасстояниеДоТекущейПозицииВрага = РасстояниеЧебышев(Корабль["Position"], Враг["Position"]);
	
	Если РасстояниеДоТекущейПозицииВрага > 5 Тогда
		ОжидаемоеПоложениеВрага = СуммаВекторов(Враг["Position"], Враг["Velocity"]);
	Иначе // в ближнем бою херачим ьез упреждения
		ОжидаемоеПоложениеВрага = Враг["Position"];
	КонецЕсли;
	ЦельВРадиусеПоражения = Орудие["Radius"] + ПоправкаНаСближение >= РасстояниеЧебышев(Корабль["Position"], ОжидаемоеПоложениеВрага);
	
	//Отладка.Добавить("R_" + ЦельВРадиусеПоражения);
	//Отладка.Добавить("D_" + РасстояниеЧебышев(Корабль["Position"], ОжидаемоеПоложениеВрага));
	//Отладка.Добавить("S_" + Корабль["Position"]);
	//Отладка.Добавить("E_" + Враг["Position"]);
	//Отладка.Добавить("O_" + ВекторСтрокой(ОжидаемоеПоложениеВрага));

	ДружественныйОгонь = ДружественныйОгонь(Корабль, ОжидаемоеПоложениеВрага);
	//ДружественныйОгонь = ложь;
	Если ЦельВРадиусеПоражения И Не ДружественныйОгонь Тогда
		Возврат Выстрел(Корабль, ОжидаемоеПоложениеВрага, Орудие);
	Иначе
		Возврат Неопределено;
	КонецЕсли
	
КонецФункции

Функция ДружественныйОгонь(Корабль, Цель)

	//ТочкаНачалаВыстрела = Корабль["Position"]; // по тупому
	ТочкаНачалаВыстрела = ТочкаНачалаВыстрела(Корабль, Цель); //по манхетонской метрике"
	
	ТочкиЛучаПоБрезенхему = ТочкиЛучаПоБрезенхему(ТочкаНачалаВыстрела, Цель);

	Для Каждого Союзник Из Корабли Цикл

		Если Корабль["Id"] = Союзник["Id"] Тогда
			Продолжить; // себе в ногу вроде не выстрелим
		КонецЕсли;

		ОжидаемеоеПоложениеСоюзника = СуммаВекторов(Союзник["Position"], Союзник["Velocity"]);
		//TODO добавить ускорение текущего хода. Должны его знать, так как сначала ходим потом стрелям

		ЦепляемСвоего = Ложь;
		Для Каждого Точка Из ТочкиЛучаПоБрезенхему Цикл
			//Если РасстояниеЧебышев(ОжидаемеоеПоложениеСоюзника, Точка) <= 1 Тогда
			Хуйня = Истина;

			Если НЕ (ОжидаемеоеПоложениеСоюзника.x - Точка.x = 0 или ОжидаемеоеПоложениеСоюзника.x - Точка.x = 1) Тогда
				Хуйня = Ложь;
			КонецЕсли;
			Если НЕ (ОжидаемеоеПоложениеСоюзника.y - Точка.y = 0 или ОжидаемеоеПоложениеСоюзника.y - Точка.y = 1) Тогда
				Хуйня = Ложь;
			КонецЕсли;
			Если НЕ (ОжидаемеоеПоложениеСоюзника.z - Точка.z = 0 или ОжидаемеоеПоложениеСоюзника.z - Точка.z = 1) Тогда
				Хуйня = Ложь;
			КонецЕсли;

			Если Хуйня Тогда 
				ЦепляемСвоего = Истина;
			КонецЕсли
		КонецЦикла;
		Если ЦепляемСвоего Тогда
			Возврат Истина;
		КонецЕсли;

	КонецЦикла;

	Возврат Ложь;

КонецФункции

Функция ПозицияКОтступлениюПоНачальнойПозиции(Корабль)
	
	ПоцияКОтступлению = НовыйВектор(0, 0, 0);
	
	УголИгрока1 = Истина;
	
	Попытка
		ПорядковыйНомер = Число(Корабль["Id"]);
		Если ПорядковыйНомер >= 10000 Тогда
			ПорядковыйНомер = ПорядковыйНомер - 10000;
			УголИгрока1 = Ложь;
		КонецЕсли;
	Исключение
		ПорядковыйНомер = 0;
	КонецПопытки;
	
	Если УголИгрока1 Тогда
		ПоцияКОтступлению = НовыйВектор(ПорядковыйНомер * 2, 0, 0);	
	Иначе
		ПоцияКОтступлению = НовыйВектор(20 + (ПорядковыйНомер * 2), 28, 28);	
	КонецЕсли;
	
	Возврат ПоцияКОтступлению;
	
КонецФункции

Функция ТочкаНачалаВыстрела(Знач Корабль, Знач Цель)

	//Из правил: Бластер стреляет по цели из ближайшей (по манхэттенской метрике) точки корабля
	//Наблюдение: Корабль задается точкой с минимальными координатами (левой верхней)

	ТочкаНачалаВыстрела = НовыйВектор(Корабль["Position"]);
	ТочкаЦели = НовыйВектор(Корабль["Position"]);

	ЦельСправа = ТочкаНачалаВыстрела.x < ТочкаЦели.x;
	Если ЦельСправа Тогда
		ТочкаНачалаВыстрела.x = ТочкаНачалаВыстрела.x + 1;
	КонецЕсли;
	
	ЦельСверху = ТочкаНачалаВыстрела.y < ТочкаЦели.y;
	Если ЦельСверху Тогда
		ТочкаНачалаВыстрела.y = ТочкаНачалаВыстрела.y + 1;
	КонецЕсли;

	ЦельСбоку = ТочкаНачалаВыстрела.z < ТочкаЦели.z;
	Если ЦельСбоку Тогда // сам хз, с какого боку
		ТочкаНачалаВыстрела.z = ТочкаНачалаВыстрела.z + 1;
	КонецЕсли;

	Возврат ТочкаНачалаВыстрела;

КонецФункции

Функция ТочкиЛучаПоБрезенхему(Знач Начало, Знач Конец)
	
	Результат = Новый Массив;
	
	Начало = НовыйВектор(Начало);
	Конец = НовыйВектор(Конец);
	
	Координаты = Новый ТаблицаЗначений;
	Координаты.Колонки.Добавить("Имя");
	Координаты.Колонки.Добавить("Расстояние");
	
	Строка = Координаты.Добавить();
	Строка.Имя = "x";
	Строка.Расстояние = МодульЧисла(Начало.x - Конец.x);
	
	Строка = Координаты.Добавить();
	Строка.Имя = "y";
	Строка.Расстояние = МодульЧисла(Начало.y - Конец.y);
	
	Строка = Координаты.Добавить();
	Строка.Имя = "z";
	Строка.Расстояние = МодульЧисла(Начало.z - Конец.z);
	
	Координаты.Сортировать("Расстояние Убыв");	
	
	Если Начало[Координаты[0].Имя] > Конец[Координаты[0].Имя] Тогда
		Буфер = Начало;
		Начало = Конец;
		Конец = Буфер;
	КонецЕсли;
	
	КоличествоИтераций = Конец[Координаты[0].Имя] - Начало[Координаты[0].Имя];
	Если КоличествоИтераций = 0 Тогда
		Результат.Добавить(Начало);
		Возврат Результат;
	КонецЕсли;
	
	Смещение = Новый Соответствие;
	ТекущаяОшибка = Новый Соответствие;
	ТекущаяКоордината = Новый Соответствие;
	Направление = Новый Соответствие;
	Для ИндексКоординаты = 1 По 2 Цикл
		Смещение[ИндексКоординаты] = МодульЧисла(Конец[Координаты[ИндексКоординаты].Имя] - Начало[Координаты[ИндексКоординаты].Имя]) / КоличествоИтераций;
		ТекущаяОшибка[ИндексКоординаты] = 0;
		ТекущаяКоордината[ИндексКоординаты] = Начало[Координаты[ИндексКоординаты].Имя];		
		Направление[ИндексКоординаты] = Конец[Координаты[ИндексКоординаты].Имя] - Начало[Координаты[ИндексКоординаты].Имя];
		Направление[ИндексКоординаты] = ?(Направление[ИндексКоординаты] > 0, 1, -1);
	КонецЦикла;
	
	Для ГланаяКоордината = Начало[Координаты[0].Имя] По Конец[Координаты[0].Имя] Цикл
		
		НовыйВектор = НовыйВектор("0/0/0");
		НовыйВектор[Координаты[0].Имя] = ГланаяКоордината;
		
		Для ИндексКоординаты = 1 По 2 Цикл
			НовыйВектор[Координаты[ИндексКоординаты].Имя] = ТекущаяКоордината[ИндексКоординаты];
			ТекущаяОшибка[ИндексКоординаты] = ТекущаяОшибка[ИндексКоординаты] + Смещение[ИндексКоординаты];
			Если ТекущаяОшибка[ИндексКоординаты] >= 0.5 Тогда
				ТекущаяОшибка[ИндексКоординаты] = ТекущаяОшибка[ИндексКоординаты] - 1;
				ТекущаяКоордината[ИндексКоординаты] = ТекущаяКоордината[ИндексКоординаты] + Направление[ИндексКоординаты];
			КонецЕсли;
		КонецЦикла;
				
		Результат.Добавить(НовыйВектор);
		
	КонецЦикла;

	Возврат Результат;

КонецФункции

Функция ЦельАтаки()

	// 1 Выбрать самого дохлого
	ТЗКорабли = МассивСоответствийВТаблицуЗначений(КораблиПротивника);
	ТЗКорабли.Колонки.Добавить("Скорость");
	ТЗКорабли.Колонки.Добавить("Доступность");

	Для Каждого Строка Из ТЗКорабли Цикл
		Строка.Скорость = МодульВектора(Строка.Velocity);

		Строка.Доступность = 0;
		Для Каждого Союзник Из Корабли Цикл
			Если ПолучитьРазрешенныйВыстрел(Союзник, Строка.ИзначальноеСоответствие) <> Неопределено Тогда
				Строка.Доступность = Строка.Доступность + 1;
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;

	ТЗКорабли.Сортировать("Доступность УБЫВ, Скорость ВОЗР, Health ВОЗР");
	//ОтсортированныеКорабли = ТаблицаЗначенийВМассивСоответствий(ТЗКорабли);
		
	Возврат ТЗКорабли[0].ИзначальноеСоответствие;
		
	// TODO 2 Среди самых дохлых выбрать самого доступного для наших кораблей

КонецФункции

Функция ТормознойПуть(Знач Скорость)
	
	Если Тип("Число") = ТипЗнч(Скорость) Тогда 
		Скорость = Скорость;
	ИначеЕсли Тип("Строка") = ТипЗнч(Скорость) Тогда
		Скорость = Число(Скорость);
	КонецЕсли;
	
	i = 1;
	j = 0;
	
	МодульСкорости = МодульЧисла(Скорость);
	
	Пока i <= МодульСкорости Цикл 
		j = j + i;
		i = i + 1;
	КонецЦикла;
	
	Возврат ?(Скорость < 0 , j * (-1), j);
	
КонецФункции

/////////////////////////////////////////////////////
// Функции связаные с текущим кораблем

Функция ОсновноеОрудиеКорабля(Корабль)
	
	Оборудование = Корабль["Equipment"];
	
	Для Каждого Элемент Из Оборудование Цикл
		
		Если Элемент["Type"] = 1 Тогда
			Возврат Элемент;
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Неопределено;	
	
КонецФункции

Функция ДвигательКорабля(Корабль)
	Оборудование = Корабль["Equipment"];
	
	Для Каждого Элемент Из Оборудование Цикл
		
		Если Элемент["Type"] = 2 Тогда
			Возврат Элемент;
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Неопределено;	
КонецФункции

/////////////////////////////////////////////////////
// Команды

Процедура ДобавитьКоманду(Команда)

	// здесь могла бы быть валидация команды

	Если Ответ["UserCommands"] = Неопределено Тогда
		Ответ.Вставить("UserCommands", Новый Массив());
	КонецЕсли;
	
	Ответ["UserCommands"].Добавить(Команда);
	
КонецПроцедуры

Функция Автопилот(КлассКорабль, Цель)
	
	Результат = Новый Структура();
	Результат.Вставить("Command", 		"MOVE");
	Результат.Вставить("Parameters", 	НовыйПараметрыАвтопилота(КлассКорабль, Цель));
	
	Возврат Результат;
	
КонецФункции

Функция Ускорение(Корабль, КоординатыЦели)
	
	Результат = Новый Структура();
	Результат.Вставить("Command",		"ACCELERATE");
	Результат.Вставить("Parameters", 	НовыйПараметрыУскорения(Корабль, КоординатыЦели));
	
	Возврат Результат;
	
КонецФункции

Функция Выстрел(Корабль, Цель, Орудие = Неопределено)
	
	Если Орудие = Неопределено Тогда
		Орудие = ОсновноеОрудиеКорабля(Корабль);
	КонецЕсли;
	
	Результат = Новый Структура();
	Результат.Вставить("Command",		"ATTACK");
	Результат.Вставить("Parameters",	НовыйПараметрыВыстрела(Корабль, Орудие, Цель));
	
	Возврат Результат;
	
КонецФункции

/////////////////////////////////////////////////////
// Сущности

Функция НовыйВектор(Знач x, Знач y = Неопределено, Знач z = Неопределено)
	
	Вектор = Новый Структура("x, y, z", 0,0,0);
	
	Если ТипЗнч(x) = Тип("Строка") Тогда
		
		ВекторСтрока    = x;
		ЭлементыВектора = Новый Массив;
		
		Для Сч = 1 По 3 Цикл
			Разделитель   = Найти(ВекторСтрока, "/");
			Если Разделитель = 0 Тогда
				ЭлементыВектора.Добавить(ВекторСтрока);
				Прервать;
			КонецЕсли;
			ЭлементВектора = Лев(ВекторСтрока, Разделитель - 1);
			ЭлементыВектора.Добавить(ЭлементВектора);
			ВекторСтрока = Сред(ВекторСтрока, Разделитель + 1)
		КонецЦикла;
		
		Если ЭлементыВектора.Количество() = 3 Тогда
			Вектор.x = Число(ЭлементыВектора[0]);
			Вектор.y = Число(ЭлементыВектора[1]);
			Вектор.z = Число(ЭлементыВектора[2]);
		КонецЕсли
		
	ИначеЕсли ТипЗнч(x) = Тип("Структура") Тогда
		
		Возврат x;
		
	Иначе
		
		Вектор.x = x;
		Вектор.y = y;
		Вектор.z = z;
		
	КонецЕсли;
	
	Возврат Вектор;
	
КонецФункции

Функция ВекторСтрокой(Вектор)
	
	Если ТипЗнч(Вектор) = Тип("Строка") Тогда
		Возврат Вектор;
	КонецЕсли;
	
	Возврат СтрШаблон("%1/%2/%3", Вектор.x, Вектор.y, Вектор.z); 
	
КонецФункции

Функция НовыйПараметрыУскорения(Корабль, КоординатыЦели)
	
	X_Корабля = Число(НовыйВектор(Корабль["Position"]).X);
	Y_Корабля = Число(НовыйВектор(Корабль["Position"]).Y);
	Z_Корабля = Число(НовыйВектор(Корабль["Position"]).Z);
	
	X_СкоростьКорабля = Число(НовыйВектор(Корабль["Velocity"]).X);
	Y_СкоростьКорабля = Число(НовыйВектор(Корабль["Velocity"]).Y);
	Z_СкоростьКорабля = Число(НовыйВектор(Корабль["Velocity"]).Z);
	
	Двигатель = ДвигательКорабля(Корабль);
	МаксимальноеУскорение = Число(Двигатель["MaxAccelerate"]);
	
	X_Цели = Число(НовыйВектор(КоординатыЦели).x);
	Y_Цели = Число(НовыйВектор(КоординатыЦели).y);
	Z_Цели = Число(НовыйВектор(КоординатыЦели).z);
	
	X_Корабля = X_Корабля + X_СкоростьКорабля;
	
	i = 1 ;
	x = Неопределено;
	y = Неопределено;
	z = Неопределено;
	
	
	//Определим на сколько можем ускорится 
	Пока i <= МаксимальноеУскорение Цикл
		
		Если X_Корабля < X_Цели Тогда
			Если X_Корабля + X_СкоростьКорабля + ТормознойПуть(X_СкоростьКорабля + i) < X_Цели Тогда
				//Отладка.Добавить("#1");
				x = i;
			КонецЕсли;
		Иначе
			Если X_Корабля + X_СкоростьКорабля + ТормознойПуть(X_СкоростьКорабля - i) > X_Цели Тогда
				//Отладка.Добавить("#2");
				x = -i;
			КонецЕсли;
		КонецЕсли;
		
		Если Y_Корабля < Y_Цели Тогда
			Если Y_Корабля + Y_СкоростьКорабля + ТормознойПуть(Y_СкоростьКорабля + i) < Y_Цели Тогда
				y = i;
			КонецЕсли;
		Иначе
			Если Y_Корабля + Y_СкоростьКорабля + ТормознойПуть(Y_СкоростьКорабля - i) > Y_Цели Тогда
				y = -i;
			КонецЕсли;
		КонецЕсли;
		
		Если Z_Корабля < Z_Цели Тогда
			Если Z_Корабля + Z_СкоростьКорабля + ТормознойПуть(Z_СкоростьКорабля + i) < Z_Цели Тогда
				z = i;
			КонецЕсли;
		Иначе
			Если Z_Корабля + Z_СкоростьКорабля + ТормознойПуть(Z_СкоростьКорабля - i) > Z_Цели Тогда
				z = -i;
			КонецЕсли;
		КонецЕсли;
		
		i = i + 1 ;
		
	КонецЦикла;
	
	//Определим можем ли дрейфовать 
	Если x = Неопределено Тогда 
		Если X_Корабля < X_Цели Тогда 
			Если X_Корабля + X_СкоростьКорабля + ТормознойПуть(X_СкоростьКорабля) < X_Цели Тогда 
				
				x = 0;
			КонецЕсли;
		Иначе 
			Если X_Корабля + X_СкоростьКорабля + ТормознойПуть(X_СкоростьКорабля) > X_Цели Тогда 
				
				x = 0;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	Если y = Неопределено Тогда 
		Если Y_Корабля < Y_Цели Тогда 
			Если Y_Корабля + Y_СкоростьКорабля + ТормознойПуть(Y_СкоростьКорабля) < Y_Цели Тогда 
				y = 0;
			КонецЕсли;
		Иначе 
			Если Y_Корабля + Y_СкоростьКорабля + ТормознойПуть(Y_СкоростьКорабля) > Y_Цели Тогда 
				y = 0;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	Если z = Неопределено Тогда 
		Если Z_Корабля < Z_Цели Тогда 
			Если Z_Корабля + Z_СкоростьКорабля + ТормознойПуть(Z_СкоростьКорабля) < Z_Цели Тогда 
				z = 0;
			КонецЕсли;
		Иначе 
			Если Z_Корабля + Z_СкоростьКорабля + ТормознойПуть(Z_СкоростьКорабля) > Z_Цели Тогда 
				z = 0;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	//Если не разгоняемся и не дрефйуем то тормозим по тормоз до упора
	Если x = Неопределено Тогда 
		Если X_СкоростьКорабля > 0 Тогда
			
			x = МаксимальноеУскорение * (-1);
		Иначе
			
			x = МаксимальноеУскорение;
		КонецЕсли;
	КонецЕсли;
	
	Если y = Неопределено Тогда 
		Если Y_СкоростьКорабля > 0 Тогда
			y = МаксимальноеУскорение * (-1);
		Иначе
			y = МаксимальноеУскорение;
		КонецЕсли;
	КонецЕсли;
	
	Если z = Неопределено Тогда 
		Если Z_СкоростьКорабля > 0 Тогда
			z = МаксимальноеУскорение * (-1);
		Иначе 
			z = МаксимальноеУскорение;
		КонецЕсли;
	КонецЕсли;
	
	//Отладка.Добавить(Строка(Корабль["Id"]) + " VEK_:" +  ВекторСтрокой(НовыйВектор(x,y,z)));
	
	Возврат Новый Структура("Id, Vector",
	Корабль["Id"],
	ВекторСтрокой(НовыйВектор(x,y,z)));
	
КонецФункции

Функция НовыйПараметрыАвтопилота(Корабль, Вектор)
	
	Возврат Новый Структура("Id, Target",
	Корабль["Id"],
	ВекторСтрокой(Вектор));
КонецФункции

Функция НовыйПараметрыВыстрела(Корабль, Орудие, Цель)
	
	Возврат Новый Структура("Id, Name, Target",
	Корабль["Id"],
	Орудие["Name"],
	ВекторСтрокой(Цель));
	
КонецФункции

Функция НовыйОтвет()
	
	Ответ = Новый Соответствие;
	Ответ.Вставить("UserCommands", Новый Массив);
	Ответ.Вставить("Message", "");
	
	Возврат Ответ;
	
КонецФункции

/////////////////////////////////////////////////////
// Вычисления

Функция РасстояниеЧебышев(Знач Позиция1, Знач Позиция2)
	
	Если ТипЗнч(Позиция1) = Тип("Строка") Тогда
		Позиция1 = НовыйВектор(Позиция1);
	КонецЕсли;
	
	Если ТипЗнч(Позиция2) = Тип("Строка") Тогда
		Позиция2 = НовыйВектор(Позиция2);
	КонецЕсли;
	
	РасстояниеX = МодульЧисла(Позиция2.X - Позиция1.X);
	РасстояниеY = МодульЧисла(Позиция2.Y - Позиция1.Y);
	РасстояниеZ	= МодульЧисла(Позиция2.Z - Позиция1.Z);
	
	Расстояние = Макс(РасстояниеX, РасстояниеY, РасстояниеZ); 
	
	Возврат Расстояние
	
КонецФункции

Функция МодульВектора(Знач Вектор)

	Если ТипЗнч(Вектор) = Тип("Строка") Тогда
		Вектор = НовыйВектор(Вектор);
	КонецЕсли;

	Возврат Макс(МодульЧисла(Вектор.x), МодульЧисла(Вектор.y), МодульЧисла(Вектор.z));

КонецФункции

Функция МодульЧисла(Значение)
	
	Возврат Макс(Значение, - Значение);
	
КонецФункции

Функция СуммаВекторов(Знач Вектор1, Знач Вектор2)
	
	Вектор1 = НовыйВектор(Вектор1);
	Вектор2 = НовыйВектор(Вектор2);
	
	Возврат НовыйВектор(Вектор1.x + Вектор2.x, Вектор1.y + Вектор2.y, Вектор1.z + Вектор2.z);
	
КонецФункции

/////////////////////////////////////////////////////
// Служебные процедуры и функции

Процедура ЦиклЖизни(ТестовыеАргументы = Неопределено)
	
	Пока Истина Цикл
		
		Если ТестовыеАргументы = Неопределено Тогда
		
			// Входящий поток
		
			ВходныеДанные  = Консоль.ПрочитатьСтроку();
			ВыходнойФайл = Неопределено;
		
		Иначе

			// Отладка через файл

			ВходнойФайл = ТестовыеАргументы[0];
			ВыходнойФайл = ТестовыеАргументы[1];
			Чтение = Новый ЧтениеТекста(ВходнойФайл);
			ВходныеДанные = Чтение.Прочитать();
			Чтение.Закрыть();

		КонецЕсли;
				
		Если НЕ ЗначениеЗаполнено(ВходныеДанные) Тогда
			Продолжить;
		КонецЕсли;
		
		Попытка
			
			ИнициализироватьОкружение(ВходныеДанные);
			ВыполнитьСценарий();	
			
		Исключение
			
			ОписаниеОшибки = ОписаниеОшибки();
			ПодготовитьОтветОписаниеОшибки(ОписаниеОшибки);		
			
		КонецПопытки;
		
		ВывестиВалидныйОтвет(ВыходнойФайл);
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ИнициализироватьОкружение(ВходныеДанные)

	// Служебные

	НомерИтерации  = НомерИтерации + 1;
	НачалоИтерации = ТекущаяУниверсальнаяДатаВМиллисекундах();

	// Новые

	Отладка = Новый Массив();
	Ответ   = НовыйОтвет();
	
	// Представления

	Состояние 	  	  = ПарсерJSON.ПрочитатьJSON(ВходныеДанные);
	Корабли 		  = Состояние["My"];
	КораблиПротивника = Состояние["Opponent"]; 	
		
КонецПроцедуры

Процедура ВывестиВалидныйОтвет(ТестовыйФайл = Неопределено)
	
	МаксимальнаяДлинаСообщения = 2000;
	
	ВалидныйОтветСтрока = ПарсерJSON.записатьJSON(Ответ);
	ВалидныйОтветСтрока = СтрЗаменить(ВалидныйОтветСтрока, Символы.ПС, "");
	ВалидныйОтветСтрока = СтрЗаменить(ВалидныйОтветСтрока, " ", "");
	
	КонецИтерации = ТекущаяУниверсальнаяДатаВМиллисекундах();
	ИтерацияВМиллисекундах  = КонецИтерации - НачалоИтерации;	
	
	НачалоСообщения = """Message"":""";
	ОтладочноеСообщение = "in:" + НомерИтерации + ";it:" + Строка(ИтерацияВМиллисекундах) + ";";
	Для Каждого Элемент Из Отладка Цикл
		ОтладочноеСообщение = ОтладочноеСообщение + Элемент + ";";
	КонецЦикла;
	
	JSON = Новый Структура;
	JSON.Вставить("k", ОтладочноеСообщение);
	
	ЭкранированыйТекст = ПарсерJSON.записатьJSON(JSON);
	ЭкранированыйТекст = СтрЗаменить(ЭкранированыйТекст, Символы.ПС, "");
	ЭкранированыйТекст = СтрЗаменить(ЭкранированыйТекст, " ", "");
	
	ОтладочноеСообщение = Сред(ЭкранированыйТекст, 7, СтрДлина(ЭкранированыйТекст) - 8);
	
	// обработка отладночго сообщения
	
	ОтладочноеСообщение = СтрЗаменить(ОтладочноеСообщение, Символы.ПС, "");
	ОтладочноеСообщение = СтрЗаменить(ОтладочноеСообщение, " ", "");
	
	// попытка вставить сообщение
	
	ВалидныйОтветСтрокаССообщением = СтрЗаменить(ВалидныйОтветСтрока, НачалоСообщения, НачалоСообщения + ОтладочноеСообщение);
	ДлинаСообщения = СтрДлина(ВалидныйОтветСтрокаССообщением);
	
	Если ДлинаСообщения > МаксимальнаяДлинаСообщения Тогда
		
		ПревышениеДлины = ДлинаСообщения - МаксимальнаяДлинаСообщения;	
		ДлинаОтладочногоСообщения = СтрДлина(ОтладочноеСообщение);
		
		Если ДлинаОтладочногоСообщения >= ПревышениеДлины Тогда
			
			ОтладочноеСообщение 			= Лев(ОтладочноеСообщение, ДлинаОтладочногоСообщения - ПревышениеДлины);
			ВалидныйОтветСтрокаПослеОбрезки = СтрЗаменить(ВалидныйОтветСтрока, НачалоСообщения, НачалоСообщения + ОтладочноеСообщение);
			
			Если СтрДлина(ВалидныйОтветСтрокаПослеОбрезки) <= МаксимальнаяДлинаСообщения Тогда
				ВалидныйОтветСтрока = ВалидныйОтветСтрокаПослеОбрезки;
			КонецЕсли
		КонецЕсли;
		
	Иначе
		
		ВалидныйОтветСтрока = ВалидныйОтветСтрокаССообщением;
		
	КонецЕсли;
	
	Если ТестовыйФайл = Неопределено Тогда
		Консоль.ВывестиСтроку(ВалидныйОтветСтрока);
	Иначе
		Запись = Новый ЗаписьТекста(ТестовыйФайл);
		Запись.Записать(ВалидныйОтветСтрока);
		Запись.Закрыть();
	КонецЕсли	
	
КонецПроцедуры

Функция ПодготовитьОтветОписаниеОшибки(ОписаниеОшибки)
	
	Ответ = Новый Соответствие();
	Ответ.Вставить("UserCommands", Новый Массив());
	Ответ.Вставить("Message"     , ОписаниеОшибки);
	
	Возврат Ответ 
	
КонецФункции

Функция МассивСоответствийВТаблицуЗначений(Массив)
	
	Результат = Новый ТаблицаЗначений();
	Если Массив.Количество() = 0 Тогда
		Возврат Результат;
	КонецЕсли;
	
	//Считаем что все соответствия одинаковы по составу полей
	ПервоеСоответствие = Массив[0];
	Для Каждого Элемент Из ПервоеСоответствие Цикл
		Результат.Колонки.Добавить(Элемент.Ключ);
	КонецЦикла;
	Результат.Колонки.Добавить("ИзначальноеСоответствие");
	
	Для Каждого Соответстие Из Массив Цикл
		НоваяСтрока = Результат.Добавить();
		Для Каждого Колонка из Результат.Колонки Цикл
			Ключ = Колонка.Имя;
			НоваяСтрока[Ключ] = Соответстие[Ключ];
		КонецЦикла;
		НоваяСтрока.ИзначальноеСоответствие = Соответстие;
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Функция ТаблицаЗначенийВМассивСоответствий(Таблица)
	
	Результат = Новый Массив;
	
	СписокКолонок = "";
	Для Каждого Колонка из Таблица.Колонки Цикл
		СписокКолонок = СписокКолонок + ?(ПустаяСтрока(СписокКолонок), "", ", ") + Колонка.Имя;	
	КонецЦикла;
	
	Для Каждого Строка из Таблица Цикл
		Соответствие = Новый Соответствие();
		Для Каждого Колонка из Таблица.Колонки Цикл
			Соответствие.Вставить(Колонка.Имя, Строка[Колонка.Имя]);
		КонецЦикла;
		Результат.Добавить(Соответствие);
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Функция ПустойОтвет()
	
	Возврат "{}";
	
КонецФункции

/////////////////////////////////////////////////////
// Основная программа

Консоль 	   = Новый Консоль();
ПарсерJSON 	   = Новый ПарсерJSON();
НомерИтерации  = 0;

Если АргументыКоманднойСтроки.Количество()>0 Тогда
	
	ЦиклЖизни(АргументыКоманднойСтроки);
	
Иначе
	
	ЦиклЖизни();
	
КонецЕсли