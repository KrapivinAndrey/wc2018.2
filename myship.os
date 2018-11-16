#Использовать asserts
#Использовать JSON


Перем Консоль;
Перем ЦентрГалактики;
Перем ПарсерJSON;


#Область Вспомогательные_функции



#КонецОбласти

Процедура ЦиклЖизни(ТестовыйПараметр = Неопределено)
	
	Если ТестовыйПараметр <> Неопределено Тогда

		ТекСостояние = ПарсерJSON.ПрочитатьJSON(ТестовыйПараметр);

		Ответ = ПодготовитьОтвет(ТекСостояние);

		ВалидныйОтвет(Ответ);

		Возврат;

	КонецЕсли;

	ВходныеДанные  = Консоль.ПрочитатьСтроку();
	Консоль.ВывестиСтроку(ПустойОтвет());

	Пока Истина Цикл

		ВходныеДанные  = Консоль.ПрочитатьСтроку();
	    Если НЕ ЗначениеЗаполнено(ВходныеДанные) Тогда
    	    Продолжить;
    	КонецЕсли;
		
		ТекСостояние = ПарсерJSON.ПрочитатьJSON(ВходныеДанные);

		Ответ = ПодготовитьОтвет(ТекСостояние);

		ВалидныйОтвет(Ответ);

	КонецЦикла;

КонецПроцедуры

Функция РазобратьJSONСостояние(ВхСтрока)

	ЧтениеJSON = Новый ЧтениеJSON();
	ЧтениеJSON.УстановитьСтроку(ВхСтрока);
	Результат = ПрочитатьJSON(ЧтениеJSON, Истина);

	Возврат Результат;
	
КонецФункции

Функция ПодготовитьОтвет(СостояниеМира)

	Ответ = Новый Соответствие();

	Для Каждого Корабль Из СостояниеМира["My"] Цикл

		ДобавитьКоманду(Ответ, Автопилот(Корабль, ЦентрГалактики));
		
	КонецЦикла;

	ДобавитьСообщение(Ответ, "Rulezzz");

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

Функция Выстрел(Корабль, Орудие, Цель)

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
    Консоль.ВывестиСтроку(ВалидныйОтветСтрока);
КонецФункции

Функция ПустойОтвет()

	Возврат "{}";

КонецФункции

#КонецОбласти

#Область Объекты

Функция НовыйВектор(x, y, z)

	Возврат Новый Структура("x, y, z",
								x,
								y,
								z)

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
								Орудие,
								ВекторСтрокой(Цель));

КонецФункции	

Функция ВекторСтрокой(Вектор)

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