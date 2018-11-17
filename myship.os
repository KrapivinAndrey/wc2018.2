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
Перем ОбщаяЦельАтаки;

Процедура ЦиклЖизни(ТестовыйПараметр = Неопределено)
	
	Пока Истина Цикл
		
		ВходныеДанные  = Консоль.ПрочитатьСтроку();
		НачалоИтерации = ТекущаяУниверсальнаяДатаВМиллисекундах();
		Если НЕ ЗначениеЗаполнено(ВходныеДанные) Тогда
			Продолжить;
		КонецЕсли;
		
		Попытка
			
			// Инициализировать контекст
			
			ИнициализироватьОкружение(ВходныеДанные);
			
			Ответ = ПодготовитьОтвет();	
			
		Исключение
			
			ОписаниеОшибки = ОписаниеОшибки();
			Ответ = ПодготовитьОтветОписаниеОшибки(ОписаниеОшибки);		
			
		КонецПопытки;
		
		ВалидныйОтвет(Ответ);
		
	КонецЦикла;
	
КонецПроцедуры

#Область Вспомогательные_функции

Процедура ИнициализироватьОкружение(ВходныеДанные)
	
	Состояние = ПарсерJSON.ПрочитатьJSON(ВходныеДанные);
	
	Корабли 		  = Состояние["My"];
	КораблиПротивника = Состояние["Opponent"]; 	
	
КонецПроцедуры

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
	
	РасстояниеX = Позиция2.X - Позиция1.X;
	РасстояниеY = Позиция2.Y - Позиция1.Y;
	РасстояниеZ	= Позиция2.Z - Позиция1.Z;
	
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
	
	Ответ = Новый Соответствие();
	ГСЧ = Новый ГенераторСлучайныхЧисел();
	
	ОбщаяЦельАтаки = ВыбратьКорабльПротивникаОбщаяЦельАтаки();
	
	Для Каждого Корабль Из Корабли Цикл
		
		РасстояниеЧебышев = РасстояниеЧебышев(Корабль["Position"], ОбщаяЦельАтаки["Position"]);		
		Орудие = ОсновноеОрудиеКорабля(Корабль); 	
		
		Если Орудие["Radius"] + 2 >= РасстояниеЧебышев Тогда
			ДобавитьКоманду(Ответ, Выстрел(Корабль, ОбщаяЦельАтаки["Position"], Орудие));	
		КонецЕсли;
	
		Позиция = НовыйВектор(Корабль["Position"]);
	
		Минимум = Мин(Позиция.X, Позиция.Y, Позиция.Z);



		Если Минимум = Позиция.X Тогда 

			ВекторДвижения = НовыйВектор(30, ГСЧ.СлучайноеЧисло(0,30), ГСЧ.СлучайноеЧисло(0,30));
			ДобавитьКоманду(Ответ, Ускорение(Корабль, ВекторДвижения));	
			Продолжить;
	
		КонецЕсли;

		Если Минимум = Позиция.Y Тогда 

			ВекторДвижения = НовыйВектор(ГСЧ.СлучайноеЧисло(0,30), 30,ГСЧ.СлучайноеЧисло(0,30));
			ДобавитьКоманду(Ответ, Ускорение(Корабль, ВекторДвижения));
			Продолжить;
		
		КонецЕсли;

		Если Минимум = Позиция.Z Тогда 

			ВекторДвижения = НовыйВектор(ГСЧ.СлучайноеЧисло(0,30), ГСЧ.СлучайноеЧисло(0,30), 30);
			ДобавитьКоманду(Ответ, Ускорение(Корабль, ВекторДвижения));
			Продолжить;
		КонецЕсли;

	//	ДобавитьКоманду(Ответ, Автопилот(Корабль, ОбщаяЦельАтаки["Position"]));
		
	КонецЦикла;
	
	

	ДобавитьСообщение(Ответ, ПарсерJSON.записатьJSON(Ответ));
	Возврат Ответ;
	
КонецФункции

Процедура ДобавитьКоманду(СоотОтвет, Команда)
	
	Если СоотОтвет["UserCommands"] = Неопределено Тогда
		СоотОтвет.Вставить("UserCommands", Новый Массив());
	КонецЕсли;
	
	СоотОтвет["UserCommands"].Добавить(Команда);
	
КонецПроцедуры

Процедура ДобавитьСообщение(Ответ, Сообщение)
	
	Ответ.Вставить("Message", Сообщение);
	
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

Функция ВалидныйОтвет(Ответ)
	
	ВалидныйОтветСтрока = ПарсерJSON.записатьJSON(Ответ);
	ВалидныйОтветСтрока = СтрЗаменить(ВалидныйОтветСтрока, Символы.ПС, "");
	ВалидныйОтветСтрока = СтрЗаменить(ВалидныйОтветСтрока, " ", "");
	
	КонецИтерации = ТекущаяУниверсальнаяДатаВМиллисекундах();
	ИтерацияВМиллисекундах  = КонецИтерации - НачалоИтерации;	
	
	НачалоСообщения = """Message"":""";
	
	ВалидныйОтветСтрока = СтрЗаменить(ВалидныйОтветСтрока, НачалоСообщения, НачалоСообщения + "it:" + Строка(ИтерацияВМиллисекундах) + ";");
	Консоль.ВывестиСтроку(ВалидныйОтветСтрока);	
	
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
	
	ЦиклЖизни(АргументыКоманднойСтроки[0]);
	
Иначе
	
	ЦиклЖизни();
	
КонецЕсли