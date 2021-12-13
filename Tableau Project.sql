--- Task 1: Create a visualization that provides a breakdown between the male and female employees working in the company each year, starting from 1990. 

Select
	year(d.from_date) as calendar_year,
   	e.gender as Gender,
    	count(e.emp_no) as number_of_employees
from
	t_employees e
join
	t_dept_emp d
on 	e.emp_no = d.emp_no 
where 	year(d.from_date) >= 1990
GROUP BY year(d.from_date), gender;

--- Task 2: Compare the number of male managers to the number of female managers from different departments for each year, starting from 1990.

select 
	d.dept_name ,
    	ee.gender ,
	dm.emp_no,
	dm.from_date,
    	dm.to_date,
    	e.calendar_year,
    	case 
		when e.calendar_year between year(dm.from_date) and year(dm.to_date) then 1
        else 0
	END as active --- CASE Statement to specialize ACTIVE Manager by the calendar year is in between start date and end date  
from 
	(select 
		year(hire_date) as calendar_year 
	 from 	t_employees
     	 GROUP BY calendar_year) e --- Create a column contains the year from the higher date of employee table must cross join the Department Table
cross join t_dept_manager dm
join t_departments d on dm.dept_no  = d.dept_no
join t_employees ee on dm.emp_no = ee.emp_no
order by dm.emp_no, calendar_year;     

--- Task 3: Compare the average salary of female versus male employees in the entire company until year 2002, and add a filter allowing you to see that per each department.
Select 
	round(avg(s.salary),2) as average_salary,
	e.gender as gender,
	d.dept_name as departments,
   	year(s.from_date) as calendar_year
from
	t_salaries s
    join t_employees e on s.emp_no = e.emp_no
    join t_dept_emp de on e.emp_no =  de.emp_no
    join t_departments d on d.dept_no = de.dept_no
group by   d.dept_no, e.gender, calendar_year
having calendar_year <=2002
order by d.dept_no;

--- Task 4: Create an SQL stored procedure that will allow you to obtain the average male and female salary per department within a certain salary range. 
--- Let this range be defined by two values the user can insert when calling the procedure.
--- Finally, visualize the obtained result-set in Tableau as a double bar chart.
delimiter $$
create PROCEDURE filter_salary( IN p_salary_min float, IN p_salary_max float) --- Create 2 input Value  in a PROCEDURE
begin
	select e.gender, d.dept_name, avg(s.salary) as average_salary
    from t_salaries s
	join t_employees e on s.emp_no = e.emp_no --- JOIN Table together
    join t_dept_emp de on e.emp_no = de.emp_no
    join t_departments d on d.dept_no = de.dept_no
	where s.salary BETWEEN p_salary_min and p_salary_max --- WHERE condition stating the salary range from 2 input VALUE
group by d.dept_no, e.gender;
end$$

delimiter ;

call filter_salary(50000,90000);
DROP PROCEDURE IF EXISTS filter_salary;
