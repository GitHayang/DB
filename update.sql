drop table prac;

CREATE TABLE PRAC
(custid varchar2(10), 
 age varchar2(3), 
 gender varchar2(2)
);

INSERT INTO PRAC (custid, age, gender) VALUES ('A13566','28', '0');
INSERT INTO PRAC (custid, age, gender) VALUES ('A14219','26', '0');
INSERT INTO PRAC (custid, age, gender) VALUES ('A15312','30', '1');
INSERT INTO PRAC (custid, age, gender) VALUES ('A16605','28', '1');
INSERT INTO PRAC (custid, age, gender) VALUES ('B10634','28', '0');
INSERT INTO PRAC (custid, age, gender) VALUES ('B16849','26', '0');
select * from PRAC
order by CUSTOMER_ID;

-- 칼럼명 변경
alter table Prac 
rename column CUSTID 
to CUSTOMER_ID;

-- 속성 변경
update PRAC
set CUSTOMER_ID = 'athena' 
where CUSTOMER_ID= 'A13566';