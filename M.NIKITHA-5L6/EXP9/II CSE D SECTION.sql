EXPERIMENT - 9

Program 1: BEFORE Trigger

1. Create the STUDENT Table


CREATE TABLE student (
    student_id   NUMBER(5) PRIMARY KEY,
    student_name VARCHAR2(50),
    course       VARCHAR2(30),
    marks        NUMBER(5,2)
);
2. Create the BEFORE INSERT Trigger
CREATE OR REPLACE TRIGGER trg_student_before_insert
BEFORE INSERT ON student
FOR EACH ROW
BEGIN

    -- Validate Student ID
    IF :NEW.student_id <= 0 THEN
        RAISE_APPLICATION_ERROR(
            -20001,
            'Student ID must be greater than 0.'
        );
    END IF;

    -- Validate Student Name
    IF :NEW.student_name IS NULL THEN
        RAISE_APPLICATION_ERROR(
            -20002,
            'Student Name cannot be NULL.'
        );
    END IF;

    -- Validate Marks
    IF :NEW.marks < 0 OR :NEW.marks > 100 THEN
        RAISE_APPLICATION_ERROR(
            -20003,
            'Marks must be between 0 and 100.'
        );
    END IF;

END;
/

3. Insert a Valid Record

INSERT INTO student
VALUES (101, 'Ravi', 'CSE', 85);

COMMIT;

4. Insert an Invalid Record
INSERT INTO student
VALUES (102, 'Sita', 'ECE', 120);
5. Test Another Invalid Record
INSERT INTO student
VALUES (-103, 'Kiran', 'EEE', 75);

6. Display the Final Table
SELECT * FROM student;


Program 2: AFTER Trigger
1. Create the Main Table

CREATE TABLE student1 (
    student1_id   NUMBER(5) PRIMARY KEY,
    student1_name VARCHAR2(50),
    course       VARCHAR2(30),
    marks        NUMBER(5,2)
);

2. Create the Audit Table
CREATE TABLE student1_audit (
    audit_id      NUMBER(5),
    student1_id    NUMBER(5),
    student1_name  VARCHAR2(50),
    course        VARCHAR2(30),
    marks         NUMBER(5,2),
    action        VARCHAR2(20),
    action_date   DATE
);

3. Create a Sequence for the Audit ID
CREATE SEQUENCE student1_audit_seq
START WITH 1
INCREMENT BY 1;
4. Create the AFTER INSERT Trigger

CREATE OR REPLACE TRIGGER trg_student1_after_insert
AFTER INSERT ON student1
FOR EACH ROW
BEGIN

    INSERT INTO student1_audit (
        audit_id,
        student1_id,
        student1_name,
        course,
        marks,
        action,
        action_date
    )
    VALUES (
        student1_audit_seq.NEXTVAL,
        :NEW.student1_id,
        :NEW.student1_name,
        :NEW.course,
        :NEW.marks,
        'INSERT',
        SYSDATE
    );

END;
/
5. Insert a New Record into the Main Table
INSERT INTO student1
VALUES (101, 'Ravi', 'CSE', 85);

COMMIT;

6. Verify the Main Table
SELECT * FROM student;
7. Display the Audit Table
SELECT * FROM student1_audit;

Program 3: Row-Level Trigger

1. Create the EMPLOYEE Table
CREATE TABLE employee (
    employee_id   NUMBER(5) PRIMARY KEY,
    employee_name VARCHAR2(50),
    department    VARCHAR2(30),
    salary        NUMBER(10,2)
);

2. Insert Sample Employee Records
INSERT INTO employee VALUES (101, 'Ravi', 'CSE', 30000);
INSERT INTO employee VALUES (102, 'Sita', 'ECE', 35000);
INSERT INTO employee VALUES (103, 'Kiran', 'EEE', 40000);
INSERT INTO employee VALUES (104, 'Anjali', 'CSE', 45000);

COMMIT;
3. Create the BEFORE UPDATE Trigger

CREATE OR REPLACE TRIGGER trg_employee_before_update
BEFORE UPDATE ON employee
FOR EACH ROW
BEGIN

    -- Compare old and new salary
    IF :NEW.salary < :OLD.salary THEN

        RAISE_APPLICATION_ERROR(
            -20001,
            'Salary cannot be decreased.'
        );

    END IF;

END;
/

4. Update a Valid Record
UPDATE employee
SET salary = 33000

WHERE employee_id = 101;

COMMIT;
5. Update an Invalid Record

UPDATE employee
SET salary = 28000

WHERE employee_id = 101;

6. Display the Table Contents
SELECT * FROM employee;

Program 4: Statement-Level Trigger
1. Create the Main Table

CREATE TABLE employee1 (
    employee1_id   NUMBER(5) PRIMARY KEY,
    employee1_name VARCHAR2(50),
    department    VARCHAR2(30),
    salary        NUMBER(10,2)
);

2. Insert Sample Records

INSERT INTO employee1 VALUES (101, 'Ravi', 'CSE', 30000);
INSERT INTO employee1 VALUES (102, 'Sita', 'ECE', 35000);
INSERT INTO employee1 VALUES (103, 'Kiran', 'EEE', 40000);
INSERT INTO employee1 VALUES (104, 'Anjali', 'CSE', 45000);
INSERT INTO employee1 VALUES (105, 'Rahul', 'ECE', 38000);

COMMIT;
3. Create the Log Table
CREATE TABLE employee1_delete_log (
    log_id        NUMBER(5),
    message       VARCHAR2(200),
    delete_date   DATE
);
4. Create a Sequence for the Log ID

CREATE SEQUENCE employee1_delete_log_seq
START WITH 1
INCREMENT BY 1;

5. Create the AFTER DELETE Statement-Level Trigger

CREATE OR REPLACE TRIGGER trg_employee_after_delete
AFTER DELETE ON employee
BEGIN

    INSERT INTO employee_delete_log (
        log_id,
        message,
        delete_date
    )
    VALUES (
        employee_delete_log_seq.NEXTVAL,
        'DELETE statement executed on EMPLOYEE table.',
        SYSDATE
    );

    DBMS_OUTPUT.PUT_LINE(
        'DELETE statement executed successfully.'
    );

END;

6. Verify the Trigger

SELECT trigger_name, status
FROM user_triggers
WHERE trigger_name = 'TRG_EMPLOYEE_AFTER_DELETE';

7. Delete One Record
SET SERVEROUTPUT ON;

DELETE FROM employee1
WHERE employee1_id = 101;

COMMIT;

8. Verify the DELETE Operation
SELECT * FROM employee1;

9. Test Statement-Level Behavior
DELETE FROM employee1
WHERE department = 'ECE';

COMMIT;
10. Display the Log Table
SELECT * FROM employee1_delete_log;

Program 5: INSTEAD OF Trigger
Create COURSE Table

CREATE TABLE course (
    course_id   NUMBER(5) PRIMARY KEY,
    course_name VARCHAR2(50)
);

Create STUDENT Table


CREATE TABLE student2 (
    student2_id   NUMBER(5) PRIMARY KEY,
    student2_name VARCHAR2(50),
    course_id    NUMBER(5),
    marks        NUMBER(5,2),
    CONSTRAINT fk_student2_course
        FOREIGN KEY (course_id)
        REFERENCES course(course_id)
);

2. Insert Sample Records
Insert Course Records
INSERT INTO course VALUES (1, 'Computer Science');
INSERT INTO course VALUES (2, 'Electronics');
INSERT INTO course VALUES (3, 'Electrical');

COMMIT;

Insert Student Records
INSERT INTO student2 VALUES (101, 'Ravi', 1, 85);
INSERT INTO student2 VALUES (102, 'Sita', 2, 90);
INSERT INTO student2 VALUES (103, 'Kiran', 3, 78);
INSERT INTO student2 VALUES (104, 'Anjali', 1, 88);

COMMIT;

3. Create a View
CREATE OR REPLACE VIEW student2_course_view AS
SELECT
    s.student2_id,
    s.student2_name,
    s.course_id,
    c.course_name,
    s.marks
FROM student2 s
JOIN course c
    ON s.course_id = c.course_id;


Display the View
SELECT * FROM student2_course_view;

4. Create the INSTEAD OF UPDATE Trigger

CREATE OR REPLACE TRIGGER trg_student2_view_update
INSTEAD OF UPDATE ON student2_course_view
FOR EACH ROW
BEGIN

    UPDATE student2
    SET
        student2_name = :NEW.student2_name,
        marks = :NEW.marks
    WHERE student2_id = :OLD.student2_id;

END;

5. Update the View
UPDATE student2_course_view
SET marks = 95
WHERE student2_id = 101;

COMMIT;
6. Verify the Base Table
SELECT * FROM student2;

7. Verify the View
SELECT * FROM student2_course_view;