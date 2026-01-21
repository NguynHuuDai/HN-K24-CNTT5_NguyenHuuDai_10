
create database project;

use project;

create table Customers(
	Customer_ID int auto_increment primary key, -- ma khach hang
    Full_Name varchar(255) not null, -- ho ten
    Phone_Number varchar(15) not null unique, -- sdt
    Email varchar(255) not null unique, -- email
    Join_Date date default (current_date) -- ngay tham gia
);

create table Insurance_Packages(
	Package_ID int auto_increment primary key, -- ma goi bao hiem
    Package_Name varchar(255) not null, -- ten goi
    Max_Limit decimal(16,2) not null check(Max_Limit > 0), -- han muc chi tra
    Base_Premium decimal(10,2) not null check(Base_Premium > 0) -- phi bao hiem co ban
);

create table Policies(
	Policy_ID int auto_increment primary key, -- ma hop dong
    Customer_ID int not null,  -- ma khach hang
    Package_ID int not null,  -- ma bao hiem
    Start_Date date not null, -- ngay bat dau
    End_Date date not null, -- ket thuc
    Status enum('Active', 'Expired', 'Cancelled') not null, -- trang thai
    foreign key (Customer_ID) references Customers(Customer_ID),
    foreign key (Package_ID) references Insurance_Packages(Package_ID)
);

create table Claims(
	Claim_ID varchar(10) primary key, -- ma yeu cau 
    Policy_ID int not null,  -- ma hop dong
    Claim_Date date not null, -- ngay yeu cau
    Claim_Amount decimal(12,2) not null check(Claim_Amount > 0), -- so tien yeu cau
    Status enum('Pending', 'Approved', 'Rejected') not null, -- trang thai
    foreign key (Policy_ID) references Policies(Policy_ID)
);

create table Claim_Processing_Log(
	Log_ID varchar(10) primary key, -- ma nhat ky 
    Claim_ID varchar(10) not null, -- ma yeu cau
    Action_Detail text not null, -- noi dung hanh dong
    Recorded_At datetime not null, -- thoi diem ghi nhan
    Processor varchar(255) not null, -- nguoi xu li
    foreign key (Claim_ID) references Claims(Claim_ID)
);

insert into Customers(Full_Name, Phone_Number, Email, Join_Date) values
('Nguyen Hoang Long', 0901112223, 'long.nh@gmail.com', '2024-01-15'),
('Tran Thi Kim Anh', 0988877766, 'anh.tk@yahoo.com', '2024-03-10'),
('Le Hoang Nam', 0903334445, 'nam.lh@outlook.com', '2025-05-20'),
('Pham Minh Duc', 0355556667, 'duc.pm@gmail.com', '2025-08-12'),
('Hoang Thu Thao', 0779998881, 'thao.ht@gmail.com', '2026-01-01');
-- select * from Customers;
insert into Insurance_Packages(Package_Name, Max_Limit , Base_Premium) values
('Bảo hiểm Sức khỏe Gold', '500000000', '5000000'),
('Bảo hiểm Ô tô Liberty', '1000000000', '15000000'),
('Bảo hiểm Nhân thọ An Bình', '2000000000', '25000000'),
('Bảo hiểm Du lịch Quốc tế', '100000000', '1000000'),
('Bảo hiểm Tai nạn 24/7', '200000000', '2500000');

insert into Policies(Start_Date, End_Date, Status) values
('2024-01-15', '2025-01-15', 'Expired'),
('2024-03-10', '2026-03-10', 'Active'),
('2024-01-15', '2025-01-15', 'Active'),
('2024-01-15', '2025-01-15', 'Expired'),
('2024-01-15', '2025-01-15', 'Active');

insert into Claim_Processing_Log(Action_Detail, Recorded_At, Processor) values
('Đã nhận hồ sơ hiện trường', '2024-06-15 09:00', 'Admin_01'),
('2024-03-10', '2026-03-10', 'Active'),
('2024-01-15', '2025-01-15', 'Active'),
('2024-01-15', '2025-01-15', 'Expired'),
('2024-01-15', '2025-01-15', 'Active');
  
update Insurance_Packages
set Base_Premium = Base_Premium * 1.15
where Max_Limit > 500000000;

delete from Claim_Processing_Log
where Recorded_At < '2025-06-20';
select *
from Policies
where Status = 'Active' and year(End_Date) = 2026;

select Full_Name, Email
from Customers
where Full_Name like '%Hoang%' and year(Join_Date) >= 2025;

select *
from Claims
order by Claim_Amount desc
limit 3 offset 1;

select c.Full_Name, i.Package_Name, p.Start_Date, cl.Claim_Amount
from Policies p
join Customers c on p.Customer_ID = c.Customer_ID
join Insurance_Packages i on p.Package_ID = i.Package_ID
left join Claims cl on cl.Policy_ID = p.Policy_ID;

select c.Full_Name, sum(cl.Claim_Amount) as Total_Approved
from Claims cl
join Policies p on cl.Policy_ID = p.Policy_ID
join Customers c on p.Customer_ID = c.Customer_ID
where cl.Status = 'Approved'
group by c.Customer_ID
having sum(cl.Claim_Amount) > 50000000;

select i.Package_Name, count(*) as Total_Customers
from Policies p
join Insurance_Packages i on p.Package_ID = i.Package_ID
group by i.Package_ID
order by Total_Customers desc
limit 1;

create index idx_policy_status_date
on Policies(Status, Start_Date);

create view vw_customer_summary as
select 
    c.Full_Name,
    count(p.Policy_ID) as Total_Policies,
    sum(i.Base_Premium) as Total_Premium
from Customers c
join Policies p on c.Customer_ID = p.Customer_ID
join Insurance_Packages i on p.Package_ID = i.Package_ID
group by c.Customer_ID;


DELIMITER $$

CREATE TRIGGER trg_block_delete_active_policy
BEFORE DELETE ON Policies
FOR EACH ROW
BEGIN
    IF OLD.Status = 'Active' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Khong the xoa du lieu';
    END IF;
END$$

DELIMITER ;

