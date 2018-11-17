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
			
			Отладка = Новый Массив();

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

Функция МыНаходимсяУСтены_ЕслиНетПоехалиКСтене(Корабли, Ответ)
	
	Для каждого Корабль из Корабли Цикл 
		
		КорабльПозиция = Корабль["Position"];
		
		Если ТипЗнч(КорабльПозиция) = Тип("Строка") Тогда
			Позиция = НовыйВектор(КорабльПозиция);
		КонецЕсли;
		
		Если Позиция.X = 0 Тогда 
			Позиция.X = 30;
			ВекторДвижения = Позиция;
			
			ДобавитьКоманду(Ответ, Ускорение(Корабль, ВекторДвижения));	
			Продолжить;
		КонецЕсли;
		
		Если Позиция.Y = 0 Тогда
			Позиция.Y = 30;
			ВекторДвижения = Позиция;
			
			ДобавитьКоманду(Ответ, Ускорение(Корабль, ВекторДвижения));	
			Продолжить;
		КонецЕсли;
		
		Если Позиция.Z = 0 Тогда
			Позиция.Z = 30;
			ВекторДвижения = Позиция;
			
			ДобавитьКоманду(Ответ, Ускорение(Корабль, ВекторДвижения));	
			Продолжить;
		КонецЕсли;
		
		РастояниеДоБлижайшейСтены = Мин(Позиция.X, Позиция.Y, Позиция.Z);
		
		Если РастояниеДоБлижайшейСтены = Позиция.X Тогда 
			
			Позиция.X = 0;
			ВекторДвижения = Позиция;
			
			Ускорение(Корабль, ВекторДвижения);
			ДобавитьКоманду(Ответ, Ускорение(Корабль, ВекторДвижения));	
		КонецЕсли;
		
		Если РастояниеДоБлижайшейСтены = Позиция.Y Тогда 
			Позиция.Y = 0;
			ВекторДвижения = Позиция;
			
			Ускорение(Корабль, ВекторДвижения);
			ДобавитьКоманду(Ответ, Ускорение(Корабль, ВекторДвижения));
		КонецЕсли;
		
		Если РастояниеДоБлижайшейСтены = Позиция.Z Тогда 
			Позиция.Z = 0;
			ВекторДвижения = Позиция;
			
			Ускорение(Корабль, ВекторДвижения);
			ДобавитьКоманду(Ответ, Ускорение(Корабль, ВекторДвижения));
		КонецЕсли;
	КонецЦикла;

КонецФункции

Функция ПодготовитьОтвет()
	
	Ответ 			   = НовыйОтвет();	
	ОбщаяЦельАтаки 	   = ВыбратьКорабльПротивникаОбщаяЦельАтаки();
	ТекущийИндексВрага = 0;
	
	Для Каждого Корабль Из Корабли Цикл

		//Каждому по цели!
		ОбщаяЦельАтаки = КораблиПротивника[ТекущийИндексВрага];
		ТекущийИндексВрага = ( ТекущийИндексВрага + 1 ) % КораблиПротивника.Количество();
		
		Отладка.Добавить("__ID__" + Корабль["Id"]);
		
		Орудие = ОсновноеОрудиеКорабля(Корабль); 	
		ЦельДоступна = Ложь;
		Выстрел = ПолучитьРазрешенныйВыстрел(Орудие, Корабль, ОбщаяЦельАтаки);
		Если Выстрел <> Неопределено Тогда
			Отладка.Добавить("MAIN_");
			ЦельДоступна = Истина;
			ДобавитьКоманду(Ответ, Выстрел);
		Иначе
			Отладка.Добавить("SEC_");
			Для Каждого Враг Из КораблиПротивника Цикл
				Выстрел = ПолучитьРазрешенныйВыстрел(Орудие, Корабль, Враг);
				Если Выстрел <> Неопределено Тогда
					ДобавитьКоманду(Ответ, Выстрел);
					Прервать	
				КонецЕсли
			КонецЦикла	
		КонецЕсли;
		
		Если ЦельДоступна Тогда

			// Организованое отступление на начальные позициии в угулу

			ПозицияКОтступлению = ПозицияКОтступлениюПоНачальнойПозиции(Корабль);
			
			Отладка.Добавить("run_"+ВекторСтрокой(ПозицияКОтступлению));

			ДобавитьКоманду(Ответ, Автопилот(Корабль, ПозицияКОтступлению));

		Иначе		
			ДобавитьКоманду(Ответ, Автопилот(Корабль, ОбщаяЦельАтаки["Position"]));
		КонецЕсли;

	КонецЦикла;
	
	//Отладка.Добавить(ПарсерJSON.ЗаписатьJSON(Ответ));

	Возврат Ответ;
	
КонецФункции

Функция ПолучитьРазрешенныйВыстрел(Орудие, Корабль, Враг)

	ПоправкаНаСближение = 1;
	
	// Пока кажется что упреждение мешает
	//ОжидаемоеПоложениеВрага = СуммаВекторов(Враг["Position"], Враг["Velocity"]);
	ОжидаемоеПоложениеВрага = Враг["Position"];

	ЦельВРадиусеПоражения = Орудие["Radius"] + ПоправкаНаСближение >= РасстояниеЧебышев(Корабль["Position"], ОжидаемоеПоложениеВрага);

	//Отладка.Добавить("R_" + ЦельВРадиусеПоражения);
	Отладка.Добавить("D_" + РасстояниеЧебышев(Корабль["Position"], ОжидаемоеПоложениеВрага));
	Отладка.Добавить("S_" + Корабль["Position"]);
	Отладка.Добавить("E_" + Враг["Position"]);
	Отладка.Добавить("O_" + ВекторСтрокой(ОжидаемоеПоложениеВрага));

	Если ЦельВРадиусеПоражения Тогда
		Возврат Выстрел(Корабль, ОжидаемоеПоложениеВрага, Орудие);
	Иначе
		Возврат Неопределено;
	КонецЕсли

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

Функция Ускорение(Корабль, ВекторУскорения)
	
	Результат = Новый Структура();
	Результат.Вставить("Command",		"ACCELERATE");
	Результат.Вставить("Parameters", 	НовыйПараметрыУскорения(Корабль, ВекторУскорения));
	
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
	ОтладочноеСообщение = "it:" + Строка(ИтерацияВМиллисекундах) + ";";

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

Функция НовыйПараметрыУскорения(Корабль, Вектор)
	
	Возврат Новый Структура("Id, Vector",
	Корабль["Id"],
	ВекторСтрокой(Вектор));
	
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


Консоль = Новый Консоль();
ПарсерJSON = Новый ПарсерJSON();
ЦентрГалактики = НовыйВектор(15,15,15);

Если АргументыКоманднойСтроки.Количество()>0 Тогда
	
	ЦиклЖизни(АргументыКоманднойСтроки);
	
Иначе
	
	ЦиклЖизни();
	
КонецЕсли