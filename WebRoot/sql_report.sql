1.
-- student info
SELECT st.first_name AS first, st.middle_name AS middle, st.last_name AS last, st.ssn AS ssn
FROM student st, student_enrollment se
WHERE st.stu_id = se.stu_id AND se.year = 2009 AND se.quarter = 'SPRING'

-- current class
SELECT ss.unit AS unit, ss.section_id AS section_id, c.class_id AS class_id, c.title AS title, c.course_id AS course_id, c.year AS year, c.quarter AS quarter
FROM student st, student_section ss, section se, class c
WHERE st.ssn = ? AND st.stu_id = ss.stu_id AND ss.section_id = se.section_id AND se.class_id = c.class_id AND c.year = 2009 AND c.quarter = 'SPRING'

2.
-- class info
SELECT cl.title AS title, cl.year AS year, cl.quarter AS quarter, co.course_number AS course_number
FROM class cl, course co
WHERE cl.course_id = co.course_id

-- roster
SELECT st.stu_id, st.ssn, st.citizen, st.pre_school, st.pre_degree, st.pre_major, st.first_name as first, st.middle_name as middle, st.last_name as last, ss.unit, ss.letter_su
FROM class cl, section se, student_section ss, student st
WHERE cl.title = ? AND se.class_id = cl.class_id AND ss.section_id = se.section_id AND ss.stu_id = st.stu_id

3.
-- student info
SELECT st.first_name AS first, st.middle_name AS middle, st.last_name AS last, st.ssn AS ssn
FROM student st
WHERE EXISTS (
    SELECT se.stu_id
    FROM student_enrollment se
    WHERE st.stu_id = se.stu_id
)

-- for class
SELECT cl.year, cl.quarter, cl.class_id, cl.title, cl.course_id, ss.grade, ss.unit, ss.letter_su
FROM student st, student_section ss, section se, class cl
WHERE st.ssn = ? AND st.stu_id = ss.stu_id AND ss.section_id = se.section_id AND se.class_id = cl.class_id
ORDER BY cl.year, cl.quarter

-- for GPA
SELECT cl.year, cl.quarter, SUM(ss.unit * co.grade_num) / SUM(ss.unit) AS grade
FROM student st, student_section ss, section se, class cl, conversion co
WHERE st.ssn = ? AND st.stu_id = ss.stu_id AND ss.section_id = se.section_id AND se.class_id = cl.class_id AND ss.letter_su = 'letter' AND ss.grade <> 'IN' AND ss.grade = co.grade_letter
GROUP BY cl.year, cl.quarter

-- for total GPA
SELECT SUM(ss.unit * co.grade_num) / SUM(ss.unit) AS grade
FROM student st, student_section ss, section se, class cl, conversion co
WHERE st.ssn = ? AND st.stu_id = ss.stu_id AND ss.section_id = se.section_id AND se.class_id = cl.class_id AND ss.letter_su = 'letter' AND ss.grade <> 'IN' AND ss.grade = co.grade_letter

4.
-- undergrad info
SELECT s.ssn, s.first_name AS first, s.middle_name AS middle, s.last_name AS last
FROM student s, student_enrollment se
WHERE s.stu_id = se.stu_id AND se.year = 2009 AND se.quarter = 'SPRING'AND NOT EXISTS (
SELECT *
FROM grad g
WHERE s.stu_id = g.stu_id
)

-- undergrad degree
SELECT name, type
FROM degree
WHERE type = 'BE' OR type = 'BA'

-- total remainunit
SELECT de.total_min_unit - SUM(ss.unit) AS remain_unit
FROM student st, student_section ss, degree de
WHERE de.name = ? AND st.ssn = ? AND st.stu_id = ss.stu_id AND ss.grade <> 'IN' AND ss.grade <> 'na'
GROUP BY de.total_min_unit

-- remain category unit
SELECT dc.cate_id, dc.min_unit - SUM(ss.unit) AS remain_cate_unit
FROM student st, student_section ss, section se, class cl, course co, degree de, degree_category dc
WHERE st.ssn = ? AND st.stu_id = ss.stu_id AND ss.grade <> 'IN' AND ss.grade <> 'na' AND ss.section_id = se.section_id AND se.class_id = cl.class_id AND cl.course_id = co.course_id
        AND de.name = ? AND de.degree_id = dc.degree_id AND dc.cate_id = co.cate_id
GROUP BY dc.cate_id, dc.min_unit

5.
-- grad info
SELECT s.ssn, s.first_name, s.middle_name, s.last_name
FROM student s, student_enrollment se
WHERE s.stu_id = se.stu_id AND se.year = 2009 AND se.quarter = 'SPRING'AND NOT EXISTS (
SELECT *
FROM undergrad u
WHERE s.stu_id = u.stu_id
)

-- grad degree
SELECT name, type
FROM degree
WHERE type = 'MS'

-- -- temp table temp1: con_id and unit
-- SELECT cc.con_id, SUM(ss.unit) AS unit
-- FROM student st, student_section ss, section se, class cl, course_concentration cc
-- WHERE st.ssn = ? AND st.stu_id = ss.stu_id AND ss.grade <> 'IN' AND ss.grade <> 'na' AND ss.section_id = se.section_id AND se.class_id = cl.class_id AND cl.course_id = cc.course_id
-- GROUP BY cc.con_id
-- -- temp table temp2: con_id and grade
-- SELECT cc.con_id, SUM(ss.unit * co.grade_num) / SUM(ss.unit) AS grade
-- FROM student st, student_section ss, section se, class cl, course_concentration cc, conversion co
-- WHERE st.ssn = ? AND st.stu_id = ss.stu_id AND ss.letter_su = 'letter' AND ss.grade <> 'IN' AND ss.grade <> 'na' AND ss.section_id = se.section_id AND se.class_id = cl.class_id AND cl.course_id = cc.course_id
--     AND ss.grade = co.grade_letter
-- GROUP BY cc.con_id

-- -- concenctration completed (GPA issue, use intersect?)
-- SELECT dc.con_id
-- FROM degree de, degree_concentration dc, temp1, temp2
-- WHERE de.name = ? AND de.degree_id = dc.degree_id AND dc.con_id = temp1.con_id AND dc.min_unit - temp1.unit <= 0 AND dc.con_id = temp2.con_id AND dc.min_grade - temp2.grade <= 0

-- use one query
SELECT con.con_name ,dc.con_id, dc.min_unit, dc.min_grade
FROM degree de, degree_concentration dc, concentration con
WHERE de.name = 'EE' AND de.degree_id = dc.degree_id AND dc.con_id = con.con_id
    AND dc.min_unit <= (
        SELECT SUM(ss.unit) AS unit
        FROM student st, student_section ss, section se, class cl, course_concentration cc
        WHERE st.ssn = 234234231 AND st.stu_id = ss.stu_id AND ss.grade <> 'IN' AND ss.grade <> 'na' AND ss.section_id = se.section_id AND se.class_id = cl.class_id AND cl.course_id = cc.course_id AND cc.con_id = dc.con_id
    ) AND dc.min_grade <= (
        SELECT SUM(ss.unit * co.grade_num) / SUM(ss.unit) AS grade
        FROM student st, student_section ss, section se, class cl, course_concentration cc, conversion co
        WHERE st.ssn = 234234231 AND st.stu_id = ss.stu_id AND ss.letter_su = 'letter' AND ss.grade <> 'IN' AND ss.grade <> 'na' AND ss.section_id = se.section_id AND se.class_id = cl.class_id AND cl.course_id = cc.course_id
            AND ss.grade = co.grade_letter AND cc.con_id = dc.con_id
    )

-- next available time. We treat the courses a student is taking this quarter as pass by default.
-- -- One query to select all courses
-- SELECT con.con_name ,dc.con_id, co.course_id, co.course_number
-- FROM degree de, degree_concentration dc, concentration con, course co, course_concentration cc
-- WHERE de.name = 'EE' AND de.degree_id = dc.degree_id AND dc.con_id = con.con_id AND con.con_id = cc.con_id AND cc.course_id = co.course_id

-- Next available time
SELECT con.con_name ,dc.con_id, co.course_id, co.course_number, cl.title, cl.year, cl.quarter
FROM degree de, degree_concentration dc, concentration con, course co, course_concentration cc, class cl, period pr
WHERE de.name = 'EE' AND de.degree_id = dc.degree_id AND dc.con_id = con.con_id AND con.con_id = cc.con_id AND cc.course_id = co.course_id AND cl.course_id = co.course_id AND cl.year = pr.year AND cl.quarter = pr.quarter
    AND co.course_id NOT IN (
        SELECT cl2.course_id
        FROM student st2, student_section ss2, section se2, class cl2
        WHERE st2.ssn = 234234231 AND st2.stu_id = ss2.stu_id AND ss2.grade <> 'IN' AND ss2.grade <> 'na' AND ss2.section_id = se2.section_id AND se2.class_id = cl2.class_id
    )
    AND pr.period_id <= (
        SELECT min(pr3.period_id)
        FROM class cl3, period pr3
        WHERE cl3.course_id = co.course_id AND cl3.year = pr3.year AND cl3.quarter = pr3.quarter
    )

6.
SELECT st.first_name AS first, st.middle_name AS middle, st.last_name AS last, st.ssn
FROM student st, student_enrollment se
WHERE st.stu_id = se.stu_id AND se.year = 2009 AND se.quarter = 'SPRING'

-- find conflict
SELECT cl1.title AS not_class_title, cl1.course_id AS not_course_id, m1.start_time AS no_start, m1.end_time AS no_end, cl2.title AS conflict_class_title, cl2.course_id AS conflict_course_id, m2.start_time AS conflict_start, m2.end_time AS conflict_end
FROM student st, section se1, class cl1, meeting m1, section se2, class cl2, meeting m2, student_section ss2
WHERE st.ssn = 323112801 AND st.stu_id = ss2.stu_id AND ss2.section_id = se2.section_id AND se2.class_id = cl2.class_id AND m2.section_id = se2.section_id AND cl2.year = 2009 AND cl2.quarter = 'SPRING'
        AND se1.class_id = cl1.class_id AND m1.section_id = se1.section_id AND cl1.year = 2009 AND cl1.quarter = 'SPRING'
        AND CAST(m2.start_time AS Time) <= CAST(m1.end_time AS Time) AND CAST(m2.end_time AS Time) >= CAST(m1.start_time AS Time) AND m2.day = m1.day AND m2.section_id <> m1.section_id

7.
-- get all section of current quarter
SELECT se.section_id, cl.course_id
FROM section se, class cl
WHERE se.class_id = cl.class_id AND cl.year = 2009 AND cl.quarter = 'SPRING'

-- put for loop out of sql. already have day-1 and date-'2015-02-07'.
-- SELECT rp.start_time AS select_start_time, rp.end_time AS select_end_time
-- FROM review_period rp
-- WHERE NOT EXISTS (
--     SELECT *
--     FROM student_section ss1, student_section ss2, section se2, class cl2, review r2, meeting m2
--     WHERE ss1.section_id = 11 AND ss1.stu_id = ss2.stu_id AND ss2.section_id = r2.section_id AND ss2.section_id = m2.section_id AND ss2.section_id = se2.section_id AND se2.class_id = cl2.class_id AND cl2.year = 2009 AND cl2.quarter = 'SPRING'
--         AND (r2.review_date = '2015-02-07' AND (CAST(r2.start_time AS Time) < CAST(rp.end_time AS Time) AND CAST(r2.end_time AS Time) > CAST(rp.start_time AS Time))
--         OR m2.day = 1 AND (CAST(m2.start_time AS Time) < CAST(rp.end_time AS Time) AND CAST(m2.end_time AS Time) > CAST(rp.start_time AS Time)))
-- )
-- ORDER BY rp.start_time
-- inner loop
SELECT aval_date::date, rp.start_time AS select_start_time, rp.end_time AS select_end_time
FROM review_period rp, generate_series('2015-02-06','2015-02-08', '1 day'::interval) aval_date
-- FROM review_period rp, generate_series(?::date, ?::date, '1 day'::interval) aval_date
WHERE NOT EXISTS (
    SELECT *
    FROM student_section ss1, student_section ss2, section se2, class cl2, review r2, meeting m2
    WHERE ss1.section_id = 11 AND ss1.stu_id = ss2.stu_id AND ss2.section_id = r2.section_id AND ss2.section_id = m2.section_id AND ss2.section_id = se2.section_id AND se2.class_id = cl2.class_id AND cl2.year = 2009 AND cl2.quarter = 'SPRING'
    -- WHERE ss1.section_id = ? AND ss1.stu_id = ss2.stu_id AND ss2.section_id = r2.section_id AND ss2.section_id = m2.section_id AND ss2.section_id = se2.section_id AND se2.class_id = cl2.class_id AND cl2.year = 2009 AND cl2.quarter = 'SPRING'
        AND (r2.review_date::date = aval_date AND (CAST(r2.start_time AS Time) < CAST(rp.end_time AS Time) AND CAST(r2.end_time AS Time) > CAST(rp.start_time AS Time))
        OR m2.day = extract(dow from aval_date::timestamp) AND (CAST(m2.start_time AS Time) < CAST(rp.end_time AS Time) AND CAST(m2.end_time AS Time) > CAST(rp.start_time AS Time)))
)
ORDER BY aval_date::date, rp.start_time

8.
-- ii
SELECT ss.grade, count(*) AS cnt
FROM class cl, section se, student_section ss
WHERE cl.course_id = ? AND cl.year = ? AND cl.quarter = ? AND cl.class_id = se.class_id AND se.fac_id = ? AND se.section_id = ss.section_id AND ss.grade <> 'IN'
GROUP BY ss.grade

-- iii
SELECT ss.grade, count(*) AS cnt
FROM class cl, section se, student_section ss
WHERE cl.course_id = ? AND cl.class_id = se.class_id AND se.fac_id = ? AND se.section_id = ss.section_id AND ss.grade <> 'IN'
GROUP BY ss.grade

-- iv
SELECT ss.grade, count(*) AS cnt
FROM class cl, section se, student_section ss
WHERE cl.course_id = ? AND cl.class_id = se.class_id AND se.section_id = ss.section_id AND ss.grade <> 'IN'
GROUP BY ss.grade

-- v
SELECT SUM(con.grade_num) / count(*) AS grade
FROM class cl, section se, student_section ss, conversion con
WHERE cl.course_id = ? AND cl.class_id = se.class_id AND se.fac_id = ? AND se.section_id = ss.section_id AND ss.grade <> 'IN' AND ss.grade = con.grade_letter


