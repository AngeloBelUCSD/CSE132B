1.
SELECT s.ssn
FROM student s, student_enrollment se
WHERE s.stu_id = se.stu_id AND se.year = 2009 AND se.quarter = 'SPRING'

SELECT st.first_name as first, st.middle_name as middle, st.last_name as last, st.ssn as ssn
FROM student st
WHERE st.ssn = ?

SELECT ss.unit as unit, ss.section_id as section_id, c.class_id as class_id, c.title as title, c.course_id as course_id, c.year as year, c.quarter as quarter
FROM student st, student_section ss, section se, class c
WHERE st.ssn = ? AND st.stu_id = ss.stu_id AND ss.section_id = se.section_id AND se.class_id = c.class_id AND c.year = 2009 AND c.quarter = 'SPRING'

2.
SELECT title
FROM class

SELECT cl.title, cl.year, cl.quarter, co.course_number
FROM class cl, course co
WHERE cl.title = ? AND cl.course_id = co.course_id

SELECT st.stu_id, st.ssn, st.citizen, st.pre_school, st.pre_degree, st.pre_major, st.first_name as first, st.middle_name as middle, st.last_name as last, ss.unit, ss.letter_su
FROM class cl, section se, student_section ss, student st
WHERE cl.title = ? AND se.class_id = cl.class_id AND ss.section_id = se.section_id AND ss.stu_id = st.stu_id

3.
SELECT ssn
FROM student

SELECT st.first_name as first, st.middle_name as middle, st.last_name as last, st.ssn as ssn
FROM student st
WHERE st.ssn = ?

SELECT cl.year, cl.quarter, SUM(ss.unit * co.grade_num) / SUM(ss.unit)
FROM student st, student_section ss, section se, class cl, conversion co
WHERE st.ssn = ? AND st.stu_id = ss.stu_id AND ss.section_id = se.section_id AND se.class_id = cl.class_id AND ss.letter_su = 'letter' AND ss.grade = co.grade_letter
GROUP BY cl.year, cl.quarter

4.
SELECT s.ssn
FROM student s, student_enrollment se
WHERE s.stu_id = se.stu_id AND se.year = 2009 AND se.quarter = 'SPRING'AND NOT EXISTS (
SELECT *
FROM grad g
WHERE s.stu_id = g.stu_id
)

SELECT name
FROM degree

SELECT ca.cate_id, dc.min_unit - SUM(ss.unit)
FROM student_section ss, section se, class cl, course co, degree d, degree_category dc, category ca
WHERE ss.stu_id = ? AND ss.section_id = se.section_id AND se.class_id = cl.class_id AND cl.course_id = co.course_id AND d.degree_id = ? AND d.degree_id = dc.degree_id AND dc.cate_id = ca.cate_id
GROUP BY ca.cate_id, dc.min_unit







