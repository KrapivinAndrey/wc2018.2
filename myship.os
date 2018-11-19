#Использовать asserts
#Использовать JSON

Перем Консоль;
Перем ЦентрГалактики;
Перем ПарсерJSON;

/////////////////////////////////////////////////////
// Окружение

Перем Состояние;
Перем Корабли;
Перем КораблиПротивника;

/////////////////////////////////////////////////////
// Вспомогательные переменные сценариев

Перем НачалоИтерации;
Перем НомерИтерации;
Перем НачальныеКоординаты;
Перем Отладка;

Процедура ЦиклЖизни(ТестовыеАргументы = Неопределено)
	
	Пока Истина Цикл
		
		Если ТестовыеАргументы = Неопределено Тогда
			ВходныеДанные  = Консоль.ПрочитатьСтроку();
			ВыходнойФайл = Неопределено;
		Иначе
			ВходнойФайл = ТестовыеАргументы[0];
			ВыходнойФайл = ТестовыеАргументы[1];
			Чтение = Новый ЧтениеТекста(ВходнойФайл);
			ВходныеДанные = Чтение.Прочитать();
			Чтение.Закрыть();
		КонецЕсли;
		НачалоИтерации = ТекущаяУниверсальнаяДатаВМиллисекундах();
		
		Если НЕ ЗначениеЗаполнено(ВходныеДанные) Тогда
			Продолжить;
		КонецЕсли;
		
		Попытка
			
			// Инициализировать контекст
			
			Отладка 	  = Новый Массив();
			НомерИтерации = НомерИтерации + 1;
			
			ИнициализироватьОкружение(ВходныеДанные);
			
			Ответ = ПодготовитьОтвет();	
			
		Исключение
			
			ОписаниеОшибки = ОписаниеОшибки();
			Ответ = ПодготовитьОтветОписаниеОшибки(ОписаниеОшибки);		
			
		КонецПопытки;
		
		ВалидныйОтвет(Ответ, ВыходнойФайл);
		
	КонецЦикла;
	
КонецПроцедуры

#Область Вспомогательные_функции

Процедура ИнициализироватьОкружение(ВходныеДанные)
	
	Состояние = ПарсерJSON.ПрочитатьJSON(ВходныеДанные);
	
	Корабли 		  = Состояние["My"];
	КораблиПротивника = Состояние["Opponent"]; 	
	
	НачальныеКоординаты = Новый Соответствие;		
	Для Каждого Корабль Из Корабли Цикл
		НачальныеКоординаты.Вставить(Корабль["Id"], Корабль["Position"]);
	КонецЦикла;
	
КонецПроцедуры

Функция НачальныеКоординатыКорабля(Корабль)
	
	НачальныеКоординатыКорабля = НачальныеКоординаты.Получить(Корабль["Id"]);
	Если ТипЗнч(НачальныеКоординатыКорабля) <> Тип("Строка") Тогда
		ВызватьИсключение ПарсерJSON.записатьJSON(НачальныеКоординаты);	
	КонецЕсли;
	
	Возврат НачальныеКоординатыКорабля;
	
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
	
	Для Каждого Соответстие Из Массив Цикл
		НоваяСтрока = Результат.Добавить();
		Для Каждого Колонка из Результат.Колонки Цикл
			Ключ = Колонка.Имя;
			НоваяСтрока[Ключ] = Соответстие[Ключ];
		КонецЦикла;
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

Функция ВыбратьКорабльПротивникаОбщаяЦельАтаки()
	
	Возврат ВыбратьСамыйДохлый();
	
КонецФункции

Функция ВыбратьПервыйПопавшийся()
	
	Для Каждого Элемент Из КораблиПротивника Цикл
		
		Если Элемент["Health"] > 0 Тогда
			Возврат Элемент;
		КонецЕсли;
		
	КонецЦикла;
	
КонецФункции

Функция ВыбратьСамыйДохлый()
	
	// 1 Выбрать самого дохлого
	ТЗКорабли = МассивСоответствийВТаблицуЗначений(КораблиПротивника);
	ТЗКорабли.Сортировать("Health");
	ОтсортированныеКорабли = ТаблицаЗначенийВМассивСоответствий(ТЗКорабли);
	
	Возврат ОтсортированныеКорабли[0];
	
	// TODO 2 Среди самых дохлых выбрать самого доступного для наших кораблей
	
КонецФункции

Функция РасстояниеЧебышев(Знач Позиция1, Знач Позиция2)
	
	// http://www.math.by/geometry/distptp.html
	
	Если ТипЗнч(Позиция1) = Тип("Строка") Тогда
		Позиция1 = НовыйВектор(Позиция1);
	КонецЕсли;
	
	Если ТипЗнч(Позиция2) = Тип("Строка") Тогда
		Позиция2 = НовыйВектор(Позиция2);
	КонецЕсли;
	
	РасстояниеX = abs(Позиция2.X - Позиция1.X);
	РасстояниеY = abs(Позиция2.Y - Позиция1.Y);
	РасстояниеZ	= abs(Позиция2.Z - Позиция1.Z);
	
	Расстояние = Макс(РасстояниеX, РасстояниеY, РасстояниеZ); 
	
	Возврат Расстояние
	
КонецФункции

Функция Расстояние(Знач Позиция1, Знач Позиция2)
	
	// http://www.math.by/geometry/distptp.html
	
	Если ТипЗнч(Позиция1) = Тип("Строка") Тогда
		Позиция1 = НовыйВектор(Позиция1);
	КонецЕсли;
	
	Если ТипЗнч(Позиция2) = Тип("Строка") Тогда
		Позиция2 = НовыйВектор(Позиция2);
	КонецЕсли;
	
	РасстояниеX = Позиция2.X - Позиция1.X;
	РасстояниеY = Позиция2.Y - Позиция1.Y;
	РасстояниеZ	= Позиция2.Z - Позиция1.Z;
	
	Расстояние = Sqrt(Pow(РасстояниеX, 2) + Pow(РасстояниеY, 2) + Pow(РасстояниеZ, 2)); 
	
	Возврат Расстояние
	
КонецФункции

#КонецОбласти

Функция РазобратьJSONСостояние(ВхСтрока)
	
	Результат = ПарсерJSON.ПрочитатьJSON(ВхСтрока);
	
	Возврат Результат;
	
КонецФункции

Функция ПодготовитьОтветОписаниеОшибки(ОписаниеОшибки)
	
	Ответ = Новый Соответствие();
	Ответ.Вставить("UserCommands", Новый Массив());
	Ответ.Вставить("Message", ОписаниеОшибки);
	
	Возврат Ответ 
	
КонецФункции


Функция ПодготовитьОтвет()
	
	Ответ 			   = НовыйОтвет();	
	ОбщаяЦельАтаки 	   = ВыбратьКорабльПротивникаОбщаяЦельАтаки();
	ЦельПеремещенияИндекс = 0;
	
	// Обработка движения кораблей
	
	Для Каждого Корабль Из Корабли Цикл
		
		// Выбор цели для перемещения
		
		ЦельПеремещения 	  = КораблиПротивника[ЦельПеремещенияИндекс];
		ЦельПеремещенияИндекс = (ЦельПеремещенияИндекс + 1) % КораблиПротивника.Количество();
		
		Если ПолучитьРазрешенныйВыстрел(Корабль, ЦельПеремещения) <> Неопределено Тогда
			ДобавитьКоманду(Ответ, Ускорение(Корабль, ПолучитьВекторУскорения(Корабль, ПозицияКОтступлениюПоНачальнойПозиции(Корабль))));		
		Иначе		
			ДобавитьКоманду(Ответ, Ускорение(Корабль, ПолучитьВекторУскорения(Корабль, ЦельПеремещения["Position"])));
		КонецЕсли;
		
	КонецЦикла;
	
	// Оработка стрельбы
	
	ЦельПеремещенияИндекс = 0;
	
	Для Каждого Корабль Из Корабли Цикл
		
		// Выбор цели для атаки
		
		ЦельПеремещения 	  = КораблиПротивника[ЦельПеремещенияИндекс];
		ЦельПеремещенияИндекс = (ЦельПеремещенияИндекс + 1) % КораблиПротивника.Количество();
		
		Выстрел = ПолучитьРазрешенныйВыстрел(Корабль, ЦельПеремещения);
		
		Если Выстрел <> Неопределено Тогда
			ДобавитьКоманду(Ответ, Выстрел);
		Иначе
			Для Каждого Враг Из КораблиПротивника Цикл
				Выстрел = ПолучитьРазрешенныйВыстрел(Корабль, Враг);
				Если Выстрел <> Неопределено Тогда
					ДобавитьКоманду(Ответ, Выстрел);
					Прервать;	
				КонецЕсли;
			КонецЦикла;	
		КонецЕсли;
		
	КонецЦикла;
	
	//Отладка.Добавить(ПарсерJSON.ЗаписатьJSON(Ответ));
	
	Возврат Ответ;
	
КонецФункции

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
			Если РасстояниеЧебышев(ОжидаемеоеПоложениеСоюзника, Точка) <= 1 Тогда
				ЦепляемСвоего = Истина;
			КонецЕсли
		КонецЦикла;
		Если ЦепляемСвоего Тогда
			Возврат Истина;
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Ложь;
	
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
	Строка.Расстояние = abs(Начало.x - Конец.x);
	
	Строка = Координаты.Добавить();
	Строка.Имя = "y";
	Строка.Расстояние = abs(Начало.y - Конец.y);
	
	Строка = Координаты.Добавить();
	Строка.Имя = "z";
	Строка.Расстояние = abs(Начало.z - Конец.z);
	
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
		Смещение[ИндексКоординаты] = abs(Конец[Координаты[ИндексКоординаты].Имя] - Начало[Координаты[ИндексКоординаты].Имя]) / КоличествоИтераций;
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

Функция abs(Значение)
	
	Возврат Макс(Значение, - Значение);
	
КонецФункции

Функция СуммаВекторов(Знач Вектор1, Знач Вектор2)
	
	Вектор1 = НовыйВектор(Вектор1);
	Вектор2 = НовыйВектор(Вектор2);
	
	Возврат НовыйВектор(Вектор1.x + Вектор2.x, Вектор1.y + Вектор2.y, Вектор1.z + Вектор2.z);
	
КонецФункции

Функция НовыйОтвет()
	
	Ответ = Новый Соответствие;
	Ответ.Вставить("UserCommands", Новый Массив);
	Ответ.Вставить("Message", "");
	
	Возврат Ответ;
	
КонецФункции

Процедура ДобавитьКоманду(СоотОтвет, Команда)
	
	Если СоотОтвет["UserCommands"] = Неопределено Тогда
		СоотОтвет.Вставить("UserCommands", Новый Массив());
	КонецЕсли;
	
	СоотОтвет["UserCommands"].Добавить(Команда);
	
КонецПроцедуры

#Область Команды_кораблю

Функция Автопилот(КлассКорабль, Цель)
	
	Результат = Новый Структура();
	Результат.Вставить("Command", 		"MOVE");
	Результат.Вставить("Parameters", 	НовыйПараметрыАвтопилота(КлассКорабль, Цель));
	
	Возврат Результат;
	
КонецФункции

Функция ПолучитьВекторУскорения(Корабль , КоординатыЦели)
	
	X_Корабля = Число(НовыйВектор(Корабль["Position"]).X);
	Y_Корабля = Число(НовыйВектор(Корабль["Position"]).Y);
	Z_Корабля = Число(НовыйВектор(Корабль["Position"]).Z);
	
	X_СкоростьКорабля = Число(НовыйВектор(Корабль["Velocity"]).X);
	Y_СкоростьКорабля = Число(НовыйВектор(Корабль["Velocity"]).Y);
	Z_СкоростьКорабля = Число(НовыйВектор(Корабль["Velocity"]).Z);
	
	X_Цели = Число(НовыйВектор(КоординатыЦели).x);
	Y_Цели = Число(НовыйВектор(КоординатыЦели).y);
	Z_Цели = Число(НовыйВектор(КоординатыЦели).z);
	
	Двигатель = ДвигательКорабля(Корабль);
	МаксимальноеУскорение = Число(Двигатель["MaxAccelerate"]);
	
	X_Цели = ?(X_Цели > 28 , 28 , X_Цели);
	X_Цели = ?(X_Цели < 0  , 0  , X_Цели);
	Y_Цели = ?(Y_Цели > 28 , 28 , Y_Цели);
	Y_Цели = ?(Y_Цели < 0  , 0  , Y_Цели);
	Z_Цели = ?(Z_Цели > 28 , 28 , Z_Цели);
	Z_Цели = ?(Z_Цели < 0  , 0  , Z_Цели);
	
	X_Корабля = X_Корабля + X_СкоростьКорабля;
	
	i = 1 ;
	x = Неопределено;
	y = Неопределено;
	z = Неопределено;
	
	Пока i <= МаксимальноеУскорение Цикл
		
		Если X_Корабля < X_Цели Тогда
			Если X_Корабля + X_СкоростьКорабля + ТормознойПуть(X_СкоростьКорабля + i) <= X_Цели Тогда
				x = i;
			КонецЕсли;
		Иначе
			Если X_Корабля + X_СкоростьКорабля + ТормознойПуть(X_СкоростьКорабля - i) >= X_Цели Тогда
				x = -i;
			КонецЕсли;
		КонецЕсли;
		
		Если Y_Корабля < Y_Цели Тогда
			Если Y_Корабля + Y_СкоростьКорабля + ТормознойПуть(Y_СкоростьКорабля + i) <= Y_Цели Тогда
				y = i;
			КонецЕсли;
		Иначе
			Если Y_Корабля + Y_СкоростьКорабля + ТормознойПуть(Y_СкоростьКорабля - i) >= Y_Цели Тогда
				y = -i;
			КонецЕсли;
		КонецЕсли;
		
		Если Z_Корабля < Z_Цели Тогда
			Если Z_Корабля + Z_СкоростьКорабля + ТормознойПуть(Z_СкоростьКорабля + i) <= Z_Цели Тогда
				z = i;
			КонецЕсли;
		Иначе
			Если Z_Корабля + Z_СкоростьКорабля + ТормознойПуть(Z_СкоростьКорабля - i) >= Z_Цели Тогда
				z = -i;
			КонецЕсли;
		КонецЕсли;
		
		i = i + 1 ;
		
	КонецЦикла;
	
	//Определим можем ли дрейфовать 
	Если x = Неопределено Тогда 
		Если X_Корабля < X_Цели Тогда 
			Если X_Корабля + X_СкоростьКорабля + ТормознойПуть(X_СкоростьКорабля) <= X_Цели Тогда 
				x = 0;
			КонецЕсли;
		Иначе 
			Если X_Корабля + X_СкоростьКорабля + ТормознойПуть(X_СкоростьКорабля) >= X_Цели Тогда 
				x = 0;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	Если y = Неопределено Тогда 
		Если Y_Корабля < Y_Цели Тогда 
			Если Y_Корабля + Y_СкоростьКорабля + ТормознойПуть(Y_СкоростьКорабля) <= Y_Цели Тогда 
				y = 0;
			КонецЕсли;
		Иначе 
			Если Y_Корабля + Y_СкоростьКорабля + ТормознойПуть(Y_СкоростьКорабля) >= Y_Цели Тогда 
				y = 0;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	Если z = Неопределено Тогда 
		Если Z_Корабля < Z_Цели Тогда 
			Если Z_Корабля + Z_СкоростьКорабля + ТормознойПуть(Z_СкоростьКорабля) <= Z_Цели Тогда 
				z = 0;
			КонецЕсли;
		Иначе 
			Если Z_Корабля + Z_СкоростьКорабля + ТормознойПуть(Z_СкоростьКорабля) >= Z_Цели Тогда 
				z = 0;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	//Если не разгоняемся и не дрефйуем то тормозим
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
	
	Возврат НовыйВектор(x,y,z);
	
	
КонецФункции

Функция Ускорение(Корабль, ВекторУскорения)
	
	Результат = Новый Структура();
	Результат.Вставить("Command",		"ACCELERATE");
	Результат.Вставить("Parameters", 	НовыйПараметрыУскорения(Корабль, ВекторУскорения));
	
	Возврат Результат;
	
КонецФункции

Функция НовыйПараметрыУскорения(Корабль, ВекторУскорения)

	Возврат Новый Структура("Id, Vector",
	Корабль["Id"],
	ВекторСтрокой(ВекторУскорения));

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

#КонецОбласти

#Область Ответы	

Функция ВалидныйОтвет(Ответ, ТестовыйФайл = Неопределено)
	
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
	
КонецФункции

Функция ПустойОтвет()
	
	Возврат "{}";
	
КонецФункции

#КонецОбласти

#Область Объекты

Функция НовыйВектор(x, y = Неопределено, z = Неопределено)
	
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

Функция НовыйПараметрыАвтопилота(Корабль, Вектор)
	
	Возврат Новый Структура("Id, Target",
	Корабль["Id"],
	ВекторСтрокой(Вектор));
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

Функция МодульЧисла(Знач Число)
	Возврат ?(Число < 0 , Число*(-1), Число);
КонецФункции

Функция НовыйПараметрыВыстрела(Корабль, Орудие, Цель)
	
	Возврат Новый Структура("Id, Name, Target",
	Корабль["Id"],
	Орудие["Name"],
	ВекторСтрокой(Цель));
	
КонецФункции	

Функция ВекторСтрокой(Вектор)
	
	Если ТипЗнч(Вектор) = Тип("Строка") Тогда
		Возврат Вектор;
	КонецЕсли;
	
	Возврат СтрШаблон("%1/%2/%3", Вектор.x, Вектор.y, Вектор.z); 
	
КонецФункции

#КонецОбласти

Функция Оборудование()
	
	Возврат Новый Структура("Energy, Gun, Engine, Health",
	0,
	1,
	2,
	3);
	
КонецФункции


Консоль 	   = Новый Консоль();
ПарсерJSON 	   = Новый ПарсерJSON();
ЦентрГалактики = НовыйВектор(15,15,15);
НомерИтерации  = 0;

Если АргументыКоманднойСтроки.Количество()>0 Тогда
	
	ЦиклЖизни(АргументыКоманднойСтроки);
	
Иначе
	
	ЦиклЖизни();
	
КонецЕсли