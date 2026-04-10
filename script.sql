GO

CREATE TABLE Faculty (
    id INT IDENTITY(1,1) PRIMARY KEY,
    faculty_name NVARCHAR(100) NOT NULL
);

CREATE TABLE Form (
    id INT IDENTITY(1,1) PRIMARY KEY,
    form_name NVARCHAR(50) NOT NULL
);

CREATE TABLE Hours (
    id INT IDENTITY(1,1) PRIMARY KEY,
    course INT NOT NULL,
    faculty_id INT FOREIGN KEY REFERENCES Faculty(id),
    form_id INT FOREIGN KEY REFERENCES Form(id),
    all_h INT NOT NULL,
    inclass_h INT NOT NULL
);

CREATE TABLE Stud (
    id INT IDENTITY(1,1) PRIMARY KEY,
    last_name NVARCHAR(50) NOT NULL,
    f_name NVARCHAR(50) NOT NULL,
    s_name NVARCHAR(50) NULL, -- Отчество (NULL или пусто для иностранцев)
    br_date DATE NOT NULL,
    in_date DATE NOT NULL,
    exm DECIMAL(4,2) NOT NULL -- Средний балл за экзамены
);

CREATE TABLE Process (
    stud_id INT FOREIGN KEY REFERENCES Stud(id),
    hours_id INT FOREIGN KEY REFERENCES Hours(id),
    PRIMARY KEY (stud_id, hours_id) -- Студент привязан к учебной группе (курсу/факультету/форме)
);

CREATE TABLE Subj (
    id INT IDENTITY(1,1) PRIMARY KEY,
    subj_name NVARCHAR(100) NOT NULL,
    hours INT NOT NULL
);

CREATE TABLE Teach (
    id INT IDENTITY(1,1) PRIMARY KEY,
    last_name NVARCHAR(50) NOT NULL,
    f_name NVARCHAR(50) NOT NULL,
    s_name NVARCHAR(50) NULL,
    br_date DATE NOT NULL,
    start_work_date DATE NOT NULL
);

CREATE TABLE Work (
    teach_id INT FOREIGN KEY REFERENCES Teach(id),
    subj_id INT FOREIGN KEY REFERENCES Subj(id),
    hours_id INT FOREIGN KEY REFERENCES Hours(id),
    PRIMARY KEY (teach_id, subj_id, hours_id) -- Преподаватель читает предмет для конкретной группы
);

INSERT INTO Faculty VALUES ('ФПК'), ('ФПМ'), ('Экономический');
INSERT INTO Form VALUES ('Очная'), ('Заочная');

-- Группы/потоки (Hours)
INSERT INTO Hours VALUES (1, 1, 1, 400, 200); -- ФПК, 1 курс, Очная
INSERT INTO Hours VALUES (3, 1, 2, 500, 150); -- ФПК, 3 курс, Заочная (сам.подг: 350ч)
INSERT INTO Hours VALUES (2, 2, 1, 450, 250); -- ФПМ, 2 курс, Очная
INSERT INTO Hours VALUES (1, 3, 2, 380, 180); -- Эконом, 1 курс, Заочная

INSERT INTO Stud VALUES 
('Иванов', 'Павел', 'Станиславович', '1998-05-10', '2020-09-01', 8.5),
('Зингел', 'Обдул', NULL, '1987-11-15', '2020-09-01', 9.0),
('Савицкая', 'Насур', '', '1999-02-20', '2021-09-01', 7.8),
('Ковальчук', 'Милана', 'Егоровна', '2000-06-17', '2022-09-01', 6.5),
('Сидоров', 'Апендикс', 'Ибрагимович', '1996-03-12', '2015-09-01', 8.0),
('Смирнова', 'Анастасия', 'Петровна', '2002-01-25', '2023-09-01', 7.2);

-- Привязка студентов к группам (Process)
INSERT INTO Process VALUES (1, 1), (2, 2), (3, 2), (4, 3), (5, 4), (6, 4);

INSERT INTO Subj VALUES 
('Математика', 120), ('Физика', 100), ('Программирование', 150), ('Базы данных', 90);

INSERT INTO Teach VALUES 
('Лебедев', 'Николай', 'Павлович', '1980-04-15', '2005-09-01'),
('Шнайдер', 'Карл', NULL, '1975-08-20', '2010-09-01'),
('Мартынов', 'Олег', 'Григорьевич', '1985-11-30', '2012-09-01');

INSERT INTO Work VALUES (1, 1, 1), (1, 2, 3), (2, 3, 2), (3, 4, 4), (3, 1, 4);


-- SELECT 1
SELECT f.faculty_name, AVG(s.exm) AS avg_exam_grade
FROM Stud s JOIN Process p ON s.id = p.stud_id
JOIN Hours h ON p.hours_id = h.id
JOIN Form fm ON h.form_id = fm.id
JOIN Faculty f ON h.faculty_id = f.id
WHERE fm.form_name = 'Заочная'
GROUP BY f.faculty_name;

-- SELECT 2
SELECT f.faculty_name, h.course, MAX(s.exm) AS max_grade
FROM Stud s JOIN Process p ON s.id = p.stud_id
JOIN Hours h ON p.hours_id = h.id
JOIN Faculty f ON h.faculty_id = f.id
GROUP BY f.faculty_name, h.course;

-- SELECT 3
SELECT f.faculty_name, AVG(s.exm) AS avg_grade
FROM Stud s JOIN Process p ON s.id = p.stud_id
JOIN Hours h ON p.hours_id = h.id
JOIN Faculty f ON h.faculty_id = f.id
GROUP BY f.faculty_name HAVING AVG(s.exm) > 7;

-- SELECT 4
SELECT f.faculty_name, h.course, fm.form_name, AVG(s.exm) AS avg_grade
FROM Stud s JOIN Process p ON s.id = p.stud_id
JOIN Hours h ON p.hours_id = h.id
JOIN Faculty f ON h.faculty_id = f.id
JOIN Form fm ON h.form_id = fm.id
GROUP BY f.faculty_name, h.course, fm.form_name HAVING AVG(s.exm) > 7.5;

-- SELECT 5
SELECT f.faculty_name, h.course, MIN(s.exm) AS min_grade
FROM Stud s JOIN Process p ON s.id = p.stud_id
JOIN Hours h ON p.hours_id = h.id
JOIN Faculty f ON h.faculty_id = f.id
GROUP BY f.faculty_name, h.course;

-- SELECT 6
SELECT f.faculty_name, fm.form_name, MIN(s.exm) AS min_grade
FROM Stud s JOIN Process p ON s.id = p.stud_id
JOIN Hours h ON p.hours_id = h.id
JOIN Faculty f ON h.faculty_id = f.id
JOIN Form fm ON h.form_id = fm.id
GROUP BY f.faculty_name, fm.form_name HAVING MIN(s.exm) > 6;

-- SELECT 7
SELECT (h.all_h - h.inclass_h) AS self_study_hours
FROM Hours h JOIN Faculty f ON h.faculty_id = f.id
JOIN Form fm ON h.form_id = fm.id
WHERE f.faculty_name = 'ФПК' AND h.course = 3 AND fm.form_name = 'Заочная';

-- SELECT 8
SELECT f.faculty_name, h.course, fm.form_name
FROM Hours h JOIN Faculty f ON h.faculty_id = f.id
JOIN Form fm ON h.form_id = fm.id
WHERE (h.all_h - h.inclass_h) > 150;

-- SELECT 9
SELECT t.last_name, COUNT(w.subj_id) AS subject_count
FROM Teach t JOIN Work w ON t.id = w.teach_id
GROUP BY t.last_name;

-- SELECT 10
SELECT f.faculty_name, COUNT(DISTINCT w.teach_id) AS teacher_count
FROM Faculty f JOIN Hours h ON f.id = h.faculty_id
JOIN Work w ON h.id = w.hours_id
GROUP BY f.faculty_name;

-- SELECT 11
SELECT s.subj_name, MAX(h.all_h) AS max_group_hours
FROM Subj s JOIN Work w ON s.id = w.subj_id
JOIN Hours h ON w.hours_id = h.id
GROUP BY s.subj_name;

-- SELECT 12
SELECT t.last_name
FROM Teach t JOIN Work w ON t.id = w.teach_id
GROUP BY t.last_name HAVING COUNT(DISTINCT w.subj_id) > 1;

-- SELECT 13
SELECT f.faculty_name, h.course, SUM(s.hours) AS total_subject_hours
FROM Hours h JOIN Faculty f ON h.faculty_id = f.id
JOIN Work w ON h.id = w.hours_id
JOIN Subj s ON w.subj_id = s.id
GROUP BY f.faculty_name, h.course;

-- SELECT 14
SELECT f.faculty_name, h.course, COUNT(DISTINCT w.subj_id) AS subj_count
FROM Faculty f JOIN Hours h ON f.id = h.faculty_id
JOIN Work w ON h.id = w.hours_id
WHERE h.course = 2
GROUP BY f.faculty_name, h.course
ORDER BY f.faculty_name DESC, h.course ASC;

-- SELECT 15
SELECT f.faculty_name, COUNT(DISTINCT w.subj_id) AS foreign_teacher_subjects
FROM Faculty f JOIN Hours h ON f.id = h.faculty_id
JOIN Work w ON h.id = w.hours_id
JOIN Teach t ON w.teach_id = t.id
WHERE t.s_name IS NULL OR LTRIM(RTRIM(t.s_name)) = ''
GROUP BY f.faculty_name;

-- JOIN 1
SELECT f.faculty_name, h.course
FROM Stud s JOIN Process p ON s.id = p.stud_id
JOIN Hours h ON p.hours_id = h.id
JOIN Faculty f ON h.faculty_id = f.id
JOIN Form fm ON h.form_id = fm.id
WHERE fm.form_name = 'Заочная' AND DATEDIFF(YEAR, s.br_date, GETDATE()) < 37;

-- JOIN 2
SELECT f.faculty_name, COUNT(s.id) AS student_count
FROM Faculty f JOIN Hours h ON f.id = h.faculty_id
JOIN Process p ON h.id = p.hours_id
JOIN Stud s ON p.stud_id = s.id
GROUP BY f.faculty_name;

-- JOIN 3
SELECT fm.form_name, COUNT(s.id) AS student_count
FROM Form fm JOIN Hours h ON fm.id = h.form_id
JOIN Process p ON h.id = p.hours_id
JOIN Stud s ON p.stud_id = s.id
GROUP BY fm.form_name;

-- JOIN 4
SELECT f.faculty_name, AVG(DATEDIFF(YEAR, s.br_date, DATEFROMPARTS(YEAR(GETDATE()), 12, 31))) AS avg_age_year_end
FROM Faculty f JOIN Hours h ON f.id = h.faculty_id
JOIN Process p ON h.id = p.hours_id
JOIN Stud s ON p.stud_id = s.id
GROUP BY f.faculty_name;

-- JOIN 5
SELECT s.in_date, f.faculty_name, h.course, fm.form_name
FROM Stud s JOIN Process p ON s.id = p.stud_id
JOIN Hours h ON p.hours_id = h.id
JOIN Faculty f ON h.faculty_id = f.id
JOIN Form fm ON h.form_id = fm.id
WHERE s.s_name IS NULL OR LTRIM(RTRIM(s.s_name)) = '';

-- JOIN 6
SELECT TOP 1 f.faculty_name, COUNT(s.id) AS enrolled_2015
FROM Faculty f JOIN Hours h ON f.id = h.faculty_id
JOIN Process p ON h.id = p.hours_id
JOIN Stud s ON p.stud_id = s.id
WHERE YEAR(s.in_date) = 2015
GROUP BY f.faculty_name ORDER BY COUNT(s.id) DESC;

-- JOIN 7
SELECT f.faculty_name, fm.form_name, COUNT(s.id) AS count_2014
FROM Faculty f JOIN Hours h ON f.id = h.faculty_id
JOIN Form fm ON h.form_id = fm.id
JOIN Process p ON h.id = p.hours_id
JOIN Stud s ON p.stud_id = s.id
WHERE YEAR(s.in_date) = 2014
GROUP BY f.faculty_name, fm.form_name;

-- JOIN 8
SELECT DISTINCT f.faculty_name, fm.form_name, h.course
FROM Faculty f JOIN Hours h ON f.id = h.faculty_id
JOIN Form fm ON h.form_id = fm.id;

-- JOIN 9
SELECT DISTINCT f.faculty_name
FROM Faculty f JOIN Hours h ON f.id = h.faculty_id
JOIN Form fm ON h.form_id = fm.id
WHERE fm.form_name = 'Заочная';

-- JOIN 10
SELECT f.faculty_name, fm.form_name, COUNT(s.id) AS student_count
FROM Faculty f JOIN Hours h ON f.id = h.faculty_id
JOIN Form fm ON h.form_id = fm.id
JOIN Process p ON h.id = p.hours_id
JOIN Stud s ON p.stud_id = s.id
GROUP BY f.faculty_name, fm.form_name;

-- JOIN 11
SELECT f.faculty_name, fm.form_name, COUNT(s.id) AS count_1_3
FROM Faculty f JOIN Hours h ON f.id = h.faculty_id
JOIN Form fm ON h.form_id = fm.id
JOIN Process p ON h.id = p.hours_id
JOIN Stud s ON p.stud_id = s.id
WHERE h.course IN (1, 3)
GROUP BY f.faculty_name, fm.form_name;

-- JOIN 12
SELECT f.faculty_name, h.course, COUNT(s.id) AS foreign_count
FROM Faculty f JOIN Hours h ON f.id = h.faculty_id
JOIN Process p ON h.id = p.hours_id
JOIN Stud s ON p.stud_id = s.id
WHERE s.s_name IS NULL OR LTRIM(RTRIM(s.s_name)) = ''
GROUP BY f.faculty_name, h.course;

-- JOIN 13
SELECT f.faculty_name, h.course, COUNT(s.id) AS high_grades
FROM Faculty f JOIN Hours h ON f.id = h.faculty_id
JOIN Process p ON h.id = p.hours_id
JOIN Stud s ON p.stud_id = s.id
WHERE s.exm > 7.5
GROUP BY f.faculty_name, h.course;

-- JOIN 14
SELECT f.faculty_name, fm.form_name, COUNT(s.id) AS over_45_count
FROM Faculty f JOIN Hours h ON f.id = h.faculty_id
JOIN Form fm ON h.form_id = fm.id
JOIN Process p ON h.id = p.hours_id
JOIN Stud s ON p.stud_id = s.id
WHERE DATEDIFF(YEAR, s.br_date, GETDATE()) > 45
GROUP BY f.faculty_name, fm.form_name;

-- JOIN 15
SELECT f.faculty_name, fm.form_name, h.course, COUNT(s.id) AS under_27_count
FROM Faculty f JOIN Hours h ON f.id = h.faculty_id
JOIN Form fm ON h.form_id = fm.id
JOIN Process p ON h.id = p.hours_id
JOIN Stud s ON p.stud_id = s.id
WHERE DATEDIFF(YEAR, s.br_date, GETDATE()) < 27
GROUP BY f.faculty_name, fm.form_name, h.course;

-- JOIN 16
SELECT f.faculty_name, COUNT(s.id) AS surname_S_count
FROM Faculty f JOIN Hours h ON f.id = h.faculty_id
JOIN Process p ON h.id = p.hours_id
JOIN Stud s ON p.stud_id = s.id
WHERE s.last_name LIKE 'С%'
GROUP BY f.faculty_name;

-- SUBQUERY 1
SELECT last_name, f_name, exm 
FROM Stud 
WHERE exm <= (SELECT MAX(exm) * 0.8 FROM Stud);

-- SUBQUERY 2
SELECT last_name, f_name, exm 
FROM Stud 
WHERE exm = (SELECT MAX(exm) FROM Stud);

-- SUBQUERY 3
SELECT s.last_name 
FROM Stud s 
JOIN Process p ON s.id = p.stud_id 
JOIN Hours h ON p.hours_id = h.id 
WHERE h.faculty_id = (
    SELECT TOP 1 h2.faculty_id 
    FROM Stud s2 
    JOIN Process p2 ON s2.id = p2.stud_id 
    JOIN Hours h2 ON p2.hours_id = h2.id 
    GROUP BY h2.faculty_id 
    ORDER BY COUNT(*) DESC
);

-- SUBQUERY 4
SELECT s.last_name, s.f_name 
FROM Stud s 
JOIN Process p ON s.id = p.stud_id 
WHERE p.hours_id NOT IN (
    SELECT p2.hours_id 
    FROM Stud s2 
    JOIN Process p2 ON s2.id = p2.stud_id 
    WHERE s2.s_name IS NULL OR LTRIM(RTRIM(s2.s_name)) = ''
);

-- SUBQUERY 5
SELECT s2.last_name, s2.f_name 
FROM Stud s2 
JOIN Process p2 ON s2.id = p2.stud_id 
JOIN Hours h2 ON p2.hours_id = h2.id 
WHERE h2.course = (SELECT h.course FROM Stud s JOIN Process p ON s.id=p.stud_id JOIN Hours h ON p.hours_id=h.id WHERE s.last_name='Ботяновский')
  AND h2.faculty_id = (SELECT h.faculty_id FROM Stud s JOIN Process p ON s.id=p.stud_id JOIN Hours h ON p.hours_id=h.id WHERE s.last_name='Ботяновский')
  AND s2.last_name <> 'Ботяновский';

-- SUBQUERY 6
SELECT s.last_name, s.f_name 
FROM Stud s 
JOIN Process p ON s.id = p.stud_id 
JOIN Hours h ON p.hours_id = h.id 
WHERE h.course IN (
    SELECT h.course FROM Stud s2 JOIN Process p2 ON s2.id=p2.stud_id JOIN Hours h ON p2.hours_id=h.id 
    WHERE s2.last_name IN ('Зингель', 'Зайцева')
) AND s.last_name NOT IN ('Зингель', 'Зайцева');

-- SUBQUERY 7
SELECT s.last_name, s.f_name 
FROM Stud s 
JOIN Process p ON s.id = p.stud_id 
WHERE p.hours_id IN (
    SELECT p2.hours_id 
    FROM Stud s2 
    JOIN Process p2 ON s2.id = p2.stud_id 
    WHERE s2.s_name IS NULL OR LTRIM(RTRIM(s2.s_name)) = ''
    GROUP BY p2.hours_id 
    HAVING COUNT(*) > 1
);

-- SUBQUERY 8
SELECT s.last_name, s.f_name, 
       (SELECT COUNT(*) FROM Stud s2 JOIN Process p2 ON s2.id=p2.stud_id WHERE p2.hours_id=p.hours_id) AS total_in_flow
FROM Stud s 
JOIN Process p ON s.id = p.stud_id 
WHERE s.s_name IS NULL OR LTRIM(RTRIM(s.s_name)) = '';

-- PROCEDURE 1
CREATE PROCEDURE usp_GetStudentCount 
    @p_fac_name NVARCHAR(100), 
    @p_form_name NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT COUNT(s.id) AS StudentCount
    FROM Stud s
    JOIN Process p ON s.id = p.stud_id
    JOIN Hours h ON p.hours_id = h.id
    JOIN Faculty f ON h.faculty_id = f.id
    JOIN Form fm ON h.form_id = fm.id
    WHERE f.faculty_name = @p_fac_name AND fm.form_name = @p_form_name;
END;
GO

-- PROCEDURE 2
CREATE PROCEDURE usp_SubjectsPerFaculty
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @v_fac_name NVARCHAR(100), @v_subj_cnt INT, @v_total_subj INT, @v_dup_cnt INT;

    -- Общее число уникальных предметов в БД
    SELECT @v_total_subj = COUNT(DISTINCT subj_id) FROM Work;
    
    -- Число предметов, встречающихся на >1 факультете
    SELECT @v_dup_cnt = COUNT(DISTINCT id) 
    FROM Subj WHERE id IN (
        SELECT w.subj_id FROM Work w 
        JOIN Hours h ON w.hours_id = h.id 
        GROUP BY w.subj_id 
        HAVING COUNT(DISTINCT h.faculty_id) > 1
    );

    DECLARE cur_faculty_data CURSOR FOR
    SELECT f.faculty_name, COUNT(DISTINCT w.subj_id)
    FROM Faculty f
    JOIN Hours h ON f.id = h.faculty_id
    JOIN Work w ON h.id = w.hours_id
    GROUP BY f.faculty_name;

    OPEN cur_faculty_data;
    FETCH NEXT FROM cur_faculty_data INTO @v_fac_name, @v_subj_cnt;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT CONCAT('Для ', @v_fac_name, ' читается ', @v_subj_cnt, ' предметов.');
        FETCH NEXT FROM cur_faculty_data INTO @v_fac_name, @v_subj_cnt;
    END;

    PRINT CONCAT('Всего ', @v_total_subj, ' предметов (из которых ', @v_dup_cnt, ' идентичны/повторяются на разных факультетах).');
    CLOSE cur_faculty_data;
    DEALLOCATE cur_faculty_data;
END;
GO

-- PROCEDURE 3
CREATE PROCEDURE usp_AddStudent
    @p_faculty NVARCHAR(100),
    @p_form NVARCHAR(50),
    @p_birth_date DATE,
    @p_enroll_date DATE,
    @p_surname NVARCHAR(50),
    @p_first_name NVARCHAR(50),
    @p_middle_name NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM Faculty WHERE faculty_name = @p_faculty)
    BEGIN RAISERROR('Факультет не найден.', 16, 1); RETURN; END;
    IF NOT EXISTS (SELECT 1 FROM Form WHERE form_name = @p_form)
    BEGIN RAISERROR('Форма обучения не найдена.', 16, 1); RETURN; END;

    DECLARE @v_fac_id INT = (SELECT id FROM Faculty WHERE faculty_name = @p_faculty);
    DECLARE @v_form_id INT = (SELECT id FROM Form WHERE form_name = @p_form);
    DECLARE @v_hours_id INT = (SELECT id FROM Hours WHERE course = 1 AND faculty_id = @v_fac_id AND form_id = @v_form_id);

    IF @v_hours_id IS NULL
    BEGIN RAISERROR('Учебная группа для 1 курса не найдена.', 16, 1); RETURN; END;

    INSERT INTO Stud (last_name, f_name, s_name, br_date, in_date, exm)
    VALUES (@p_surname, @p_first_name, @p_middle_name, @p_birth_date, @p_enroll_date, 0.0);

    DECLARE @v_new_stud_id INT = SCOPE_IDENTITY();
    INSERT INTO Process (stud_id, hours_id) VALUES (@v_new_stud_id, @v_hours_id);
    PRINT 'Студент успешно зачислен.';
END;
GO

-- FUNCTION 1
CREATE FUNCTION dbo.fn_CheckCitizenship (@p_check_name NVARCHAR(50))
RETURNS NVARCHAR(20)
AS
BEGIN
    RETURN CASE 
        WHEN @p_check_name IS NULL OR LTRIM(RTRIM(@p_check_name)) = '' THEN 'Иностранец'
        ELSE 'Гражданин'
    END;
END;
GO

-- FUNCTION 2
CREATE FUNCTION dbo.fn_GetTeacherLoad (@p_teach_id INT)
RETURNS INT
AS
BEGIN
    DECLARE @v_load INT;
    SELECT @v_load = ISNULL(SUM(h.all_h), 0)
    FROM Work w
    JOIN Hours h ON w.hours_id = h.id
    WHERE w.teach_id = @p_teach_id;
    RETURN @v_load;
END;
GO

-- VIEWS

-- SELECT id, last_name, dbo.fn_GetTeacherLoad(id) AS total_hours FROM Teach;

-- ФИО, курс, форма обучения всех студентов ФПК
CREATE VIEW v_FPK_Students AS
SELECT s.last_name, s.f_name, s.s_name, h.course, fm.form_name
FROM Stud s
JOIN Process p ON s.id = p.stud_id
JOIN Hours h ON p.hours_id = h.id
JOIN Faculty f ON h.faculty_id = f.id
JOIN Form fm ON h.form_id = fm.id
WHERE f.faculty_name = 'ФПК';
GO

-- Факультет, курс, количество общих часов (заочная группа)
CREATE VIEW v_Correspondence_Hours AS
SELECT f.faculty_name, h.course, SUM(h.all_h) AS total_hours
FROM Hours h
JOIN Faculty f ON h.faculty_id = f.id
JOIN Form fm ON h.form_id = fm.id
WHERE fm.form_name = 'Заочная'
GROUP BY f.faculty_name, h.course;
GO

-- Отличники (exm > 8) по курсу-факультету-форме
CREATE VIEW v_Excellent_Students AS
SELECT f.faculty_name, h.course, fm.form_name, COUNT(*) AS excellent_count, AVG(s.exm) AS avg_exm
FROM Stud s
JOIN Process p ON s.id = p.stud_id
JOIN Hours h ON p.hours_id = h.id
JOIN Faculty f ON h.faculty_id = f.id
JOIN Form fm ON h.form_id = fm.id
WHERE s.exm > 8
GROUP BY f.faculty_name, h.course, fm.form_name;
GO

-- Слабоуспевающие (exm < 6) и их средний балл
CREATE VIEW v_Poor_Students AS
SELECT f.faculty_name, h.course, fm.form_name, COUNT(*) AS poor_count, AVG(s.exm) AS avg_exm
FROM Stud s
JOIN Process p ON s.id = p.stud_id
JOIN Hours h ON p.hours_id = h.id
JOIN Faculty f ON h.faculty_id = f.id
JOIN Form fm ON h.form_id = fm.id
WHERE s.exm < 6
GROUP BY f.faculty_name, h.course, fm.form_name;
GO

-- 2. Какие представления модифицируемые, а какие только для чтения?
/*
Все созданные представления (v_FPK_Students, v_Correspondence_Hours, v_Excellent_Students, v_Poor_Students) 
являются ТОЛЬКО ДЛЯ ЧТЕНИЯ в SQL Server, так как они содержат:
- JOIN нескольких таблиц
- Агрегатные функции (COUNT, AVG, SUM)
- GROUP BY / HAVING
В SQL Server представления с агрегацией и соединениями не поддерживают прямые операции INSERT/UPDATE/DELETE. 
Для их модификации требуются триггеры INSTEAD OF или прямое изменение базовых таблиц.
Представление v_FPK_Students теоретически могло бы быть обновляемым, но из-за JOIN оно тоже становится read-only без INSTEAD OF триггеров.
*/

-- UNION 1
SELECT t.last_name, t.f_name, SUM(h.all_h) AS total_hours, SUM(h.all_h) * 1.20 AS load_with_bonus
FROM Teach t JOIN Work w ON t.id = w.teach_id JOIN Hours h ON w.hours_id = h.id
GROUP BY t.id, t.last_name, t.f_name
HAVING SUM(h.all_h) > 450
UNION ALL
SELECT t.last_name, t.f_name, SUM(h.all_h), SUM(h.all_h) * 1.10
FROM Teach t JOIN Work w ON t.id = w.teach_id JOIN Hours h ON w.hours_id = h.id
GROUP BY t.id, t.last_name, t.f_name
HAVING SUM(h.all_h) >= 300 AND SUM(h.all_h) <= 450
UNION ALL
SELECT t.last_name, t.f_name, SUM(h.all_h), SUM(h.all_h) * 1.00
FROM Teach t JOIN Work w ON t.id = w.teach_id JOIN Hours h ON w.hours_id = h.id
GROUP BY t.id, t.last_name, t.f_name
HAVING SUM(h.all_h) < 300;

-- UNION 2
SELECT last_name, CASE WHEN s_name IS NULL OR LTRIM(RTRIM(s_name)) = '' THEN 'Иностранное' ELSE 'РБ' END AS citizenship
FROM Stud
UNION ALL
SELECT last_name, CASE WHEN s_name IS NULL OR LTRIM(RTRIM(s_name)) = '' THEN 'Иностранное' ELSE 'РБ' END AS citizenship
FROM Teach;

-- UNION 3
SELECT t.id, t.last_name 
FROM Teach t JOIN Work w ON t.id=w.teach_id JOIN Hours h ON w.hours_id=h.id JOIN Faculty f ON h.faculty_id=f.id WHERE f.faculty_name='ФПК'
INTERSECT
SELECT t.id, t.last_name 
FROM Teach t JOIN Work w ON t.id=w.teach_id JOIN Hours h ON w.hours_id=h.id JOIN Faculty f ON h.faculty_id=f.id WHERE f.faculty_name='ФПМ';

-- UNION 4
SELECT t.id, t.last_name 
FROM Teach t JOIN Work w ON t.id=w.teach_id JOIN Hours h ON w.hours_id=h.id JOIN Faculty f ON h.faculty_id=f.id WHERE f.faculty_name='ФПК'
EXCEPT
SELECT t.id, t.last_name 
FROM Teach t JOIN Work w ON t.id=w.teach_id JOIN Hours h ON w.hours_id=h.id JOIN Faculty f ON h.faculty_id=f.id WHERE f.faculty_name='ФПМ';

-- UNION 5
SELECT 'Студентов' AS Category, COUNT(*) AS Quantity FROM Stud
UNION ALL
SELECT 'Преподавателей', COUNT(*) FROM Teach
UNION ALL
SELECT 'Всего человек', COUNT(*) FROM (SELECT id FROM Stud UNION ALL SELECT id FROM Teach) AS Combined;

EXEC usp_GetStudentCount 'ФПК', 'Очная';
EXEC usp_SubjectsPerFaculty;
EXEC usp_AddStudent 'ФПК', 'Очная', '1999-01-01', '2023-09-01', 'Лобанов', 'Семён', 'Андреевич';
