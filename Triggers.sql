--1.   Написать DML-триггер, регистрирующий изменение данных (вставку, обновление, удаление) в одной из таблиц БД. Во вспомогательную таблицу LOG1 записывать, кто, когда (дата и время) и какое именно изменение произвел, для одного из столбцов сохранять старые и новые значения.

--2.   Написать DDL-триггер, протоколирующий действия пользователей по созданию, изменению и удалению таблиц в схеме во вспомогательную таблицу LOG2 в определенное время и запрещающий эти действия в другое время.

--3.   Написать системный триггер, добавляющий запись во вспомогательную таблицу LOG3, когда пользователь подключается или отключается. В таблицу логов записывается имя пользователя (USER), тип активности (LOGON или LOGOFF), дата (SYSDATE), количество записей в основной таблице БД.

--4.   Написать триггеры, реализующие бизнес-логику (ограничения) в заданной вариантом предметной области. Три задания приведены в прил. 6. Количество и тип триггеров (строковый или операторный, выполняется AFTER или BEFORE) определять самостоятельно исходя из сути заданий и имеющейся схемы БД; учесть, что в некоторых вариантах первые два задания могут быть выполнены в рамках одного триггера, а также возможно возникновение мутации, что приведет к совмещению данного пункта лабораторной работы со следующим. Третий пункт задания предполагает использование планировщика задач, который обязательно должен быть настроен на многократный запуск с использованием частоты, интервала и спецификаторов (можно не делать вечерникам).

--5.   Самостоятельно или при помощи преподавателя составить задание на триггер, который будет вызывать мутацию таблиц, и решить эту проблему одним из двух способов (при помощи переменных пакета и двух триггеров или при помощи COMPAUND-триггера). --можно не делать вечерникам

--6.   Написать триггер INSTEAD OF для работы с необновляемым представлением, созданным после выполнения п. 4 задания к лабораторной работе №3, проверить DML-командами возможность обновления представления после включения триггера.

--SERGEEV V. A.

-----Trigger1
CREATE OR REPLACE Trigger DML_Trigger
after insert or update or delete
on Posts 
FOR EACH ROW


DECLARE


change_type VARCHAR2(50);
old_value VARCHAR2(50);
new_value VARCHAR2(50);


BEGIN

CASE
When inserting then
change_type := 'Insert';
new_value := :NEW.Name_post;

When updating then
change_type := 'Update';
old_value := :OLD.Name_post;
new_value := :NEW.Name_post;


When deleting then 
change_type := 'Delete';
old_value := :OLD.Name_post;

End CASE;


insert into Log1 (User_name, change_date, type_of_change, old_Name_post, new_Name_post)
Values (User, Systimestamp, change_type, old_value, new_value );

end;
/
--------------------------------------------------------------------------
insert into Posts values ('4', 'King', '5000.00');
update Posts set Name_post = 'Kingggggg' where Posts_key = '4';
delete from Posts Where Posts_key = '4';
---------------------------------------------------------------------------
CREATE TABLE Log1
                (User_name VARCHAR2(50),
                change_date timestamp,
                type_of_change VARCHAR2(50),
                old_Name_post VARCHAR2(50),
                new_Name_post VARCHAR2(50)
                );


------Trigger2
CREATE OR REPLACE Trigger DDL_Trigger
before create or alter or drop
on schema

BEGIN
if to_char(sysdate, 'HH24') < 15 then 

insert into Log2 values (User, systimestamp, ora_dict_obj_name, ora_sysevent);

else

Raise_application_error (num => -20000, msg => 'Не то время');

end if;
end;
/

CREATE TABLE Log2
                (User_name VARCHAR2(50),
                change_date timestamp,
                name_of_table VARCHAR2(50),
                type_of_change VARCHAR2(50)
                );



create table Test_1
                  (Second_name VARCHAR2(20), 
                  First_name VARCHAR2(20)
                  )

alter table Test_1 modify Second_name char(20);

drop table Test_1 purge

ALTER TRIGGER DDL_Trigger DISABLE;


-----Trigger 3

create or replace trigger SYS_Trigger1
before Logoff
on schema

Declare 
numbers_rows number;

BEGIN

select count (Staffing_table_key) into numbers_rows
from Staffing_table;

insert into Log3 values (ora_login_user, 'LOGOFF', systimestamp, numbers_rows);

end;
/

create or replace trigger SYS_Trigger2
After Logon
on schema

Declare
numbers_rows number;

BEGIN

select count (Staffing_table_key) into numbers_rows
from Staffing_table;

insert into Log3 values (ora_login_user, 'LOGON', systimestamp, numbers_rows);

end;
/

CREATE TABLE Log3
                (User_name VARCHAR2(50),
                type_of_activity VARCHAR2(50)
                change_date timestamp,
                rows_number VARCHAR2(50)
                )



--Вариант 19
--1)	Рассчитывать заработную плату сотрудников в зависимости от окла-да и процента участия в разработках.
--2)	Отслеживать, чтобы сотрудник одновременно работал не более чем на 1,5 ставки и совмещал не более трех должностей, также он не может рабо-тать одновременно более чем над тремя разработками и более чем в двух от-делах.
3--)	Во вспомогательную таблицу регулярно вносить информацию о ве-дущихся в отделе разработках с указанием количества участвующих сотруд-ников, датах начала и окончания.



-----Trigger4
create or replace trigger trigger4
BEFORE UPDATE OF Number_persons
on Departments
for each row

declare

a1 number;

Begin 
select Number_persons into a1 from Departments
where Department_key = :new.Department_key;

if :new.Number_persons < 5 then
raise_application_error (-20001, 'Превышено максимальное количество человек в отделе' || :new.Number_persons);
end if;
end;
/



insert into Departments values ('7', 'Dinistor', '7', 'Vlad'); ----- ОШИБКА!!

delete from Departments Where Department_key = '7';