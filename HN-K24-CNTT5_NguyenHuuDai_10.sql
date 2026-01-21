
create database project;

use project;

create table Customers(
	Customer_ID int auto_increment primary key, -- ma khach hang
    Full_Name varchar(255) not null, -- ho ten
    Phone_Number varchar(15) not null unique, -- sdt
    Email varchar(255) not null unique, -- email
    Join_Date date default(now()) -- ngay tham gia
);

create table Insurance_Packages(
	Package_ID int auto_increment primary key, -- ma goi bao hiem
    Package_Name varchar(255) not null, -- ten goi
    Max_Limit decimal(16,2) check(Max_Limit > 0), -- han muc chi tra
    Base_Premium decimal(10,2) not null -- phi bao hiem co ban
);

create table Policies(
	Policy_ID int auto_increment primary key, -- ma hop dong
    Customer_ID int not null,  -- ma khach hang
    Package_ID  int not null ,  -- ma bao hiem
    Start_Date date, -- ngay bat dau
    End_Date date, -- ket thuc
    Status enum('Active', 'Expired', 'Cancelled'), -- trang thai
    foreign key (Customer_ID) references Customers(Customer_ID),
    foreign key (Package_ID) references Insurance_Packages(Package_ID)
);
create table Claims(
	Claim_ID int auto_increment primary key, -- ma yeu cau
    Policy_ID int not null unique,  -- ma hop dong
    Claim_Date  date not null unique, -- ngay y/c
    Claim_Amount  decimal(10,2) not null unique, -- so tien y/c
    Status enum('Pending', 'Approved', 'Rejected'), -- trang thai
    foreign key (Policy_ID) references Policies(Policy_ID)
);
create table Claim_Processing_Log(
	Log_ID int auto_increment primary key, -- ma nhat ky
    Claim_ID int not null unique, -- ma y/c
    Action_Detail  text not null, -- noi dung
    Recorded_At  datetime, -- thoi diem ghi nhan
    Processor varchar(255) not null unique, -- nguoi xu li
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
  

select * 
from Policies
where End_Date = 2026;

select Full_Name, Email
from Customers
where Full_Name Like 'Hoàng%';

select *
from Claims
order by Claim_Amount
limit 1 offset 3;

select c.Full_Name, i.Package_Name, p.Start_Date
from Customers c
join Insurance_Packages i on c.Package_Name = i.Package_Name
join Policies p on c.Start_Date = p.Start_Date;


