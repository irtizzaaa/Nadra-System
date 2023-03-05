use master
drop database Nadra
go
create database Nadra
GO
USE [Nadra]
GO

create table member_Login(CNIC varchar(15) NOT NULL,
	[password] varchar(MAX) NOT NULL,
	PRIMARY KEY (CNIC)
)
go
create table admin_login(
	CNIC varchar(15) NOT NULL,
	[password] varchar(MAX) NOT NULL,
	PRIMARY KEY (CNIC),
	constraint FK_cnic_ad_login Foreign KEY (CNIC) references member_Login(CNIC)
)

go
create table Diseases(
	CNIC varchar(15) NOT NULL,
	diseases varchar(50) NOT NULL,
	constraint FK_cnic_diseases Foreign KEY (CNIC) references member_Login(CNIC)
)
go
create table Vaccine(
	CNIC varchar(15) NOT NULL,
	vaccine varchar(50) NOT NULL,
	constraint FK_cnic_vaccine Foreign KEY (CNIC) references member_Login(CNIC)
)
go
create table car(
	CNIC varchar(15) NOT NULL,
	car varchar(50) NOT NULL,
	numberplate varchar(7) NOT NULL,
	primary key(numberplate),
	constraint FK_cnic_car Foreign KEY (CNIC) references member_Login(CNIC)
)
go
create table property(
	CNIC varchar(15) NOT NULL,
	house_number varchar(50) NOT NULL,
	address Varchar(100) NOT NULL,
	city varchar(50) NOT NULL,
	primary key(house_number,address,city),
	constraint FK_cnic_property Foreign KEY (CNIC) references member_Login(CNIC)
)
--drop table property
go
create table sims (
	CNIC varchar(15) NOT NULL,
	number varchar(11),
	company varchar(20),
	status  varchar(9),
	primary key(number),
	constraint FK_cnic_sims Foreign KEY (CNIC) references member_Login(CNIC),
	check(status in ('active','Nonactive'))
)
--drop table sims
go
create table visa(
	CNIC varchar(15) NOT NULL,
	country varchar(20),
	primary key(CNIC,country),
	constraint FK_cnic_visa Foreign KEY (CNIC) references member_Login(CNIC)
)
--drop table visa
go
create table pinfo(
	CNIC varchar(15) NOT NULL,
	[Name]  varchar(50) NOT NULL,
	DOB varchar(15) NOT NULL,
	Gender varchar(1) NOT NULL ,
	spouse varchar(50),
	primary key(CNIC),
	constraint FK_cnic_pinfo Foreign KEY (CNIC) references member_Login(CNIC),
	check(Gender in ('M','F','O'))
)
go
create table finance(
	CNIC varchar(15) NOT NULL,
	bill varchar(MAX),
	dues int,
	[status] varchar(6),
	constraint FK_cnic_fina Foreign KEY (CNIC) references member_Login(CNIC),
	check (bill in ('Paid','Unpaid'))
)
create table complaints(
	CNIC varchar(15) NOT NULL,
	description varchar(MAX)NOT NULL,
	[status] varchar(7),
	constraint FK_cnic_complaint Foreign KEY (CNIC) references member_Login(CNIC),
	check ([status] in ('done','Undone'))
)

create table requests(
	CNIC varchar(15) NOT NULL,
	description varchar(MAX)NOT NULL,
	[status] varchar(10),
	constraint FK_cnic_requests Foreign KEY (CNIC) references member_Login(CNIC),
	check ([status] in ('Complete','Incomplete'))
)
create table offices(
	City varchar(30) NOT NULL,
	address varchar(50) NOT NULL,
	primary key(City,address)
)
insert into offices values('Lahore','Kareem Block,Iqbal Town')
insert into offices values('Karachi','Kareem Block,Iqbal Town')

--INSERT INTO [dbo].[requests]
--           ([CNIC]
--           ,[description],[status])
--     VALUES('35202-1908609-9','Plese add into my sims Company Jazz ,Number=03239943122','Incomplete')
	 --delete from requests where CNIC='35202-1908609-9'
GO
--delete from requests where CNIC='35202-1908609-9'

--INSERT INTO [dbo].[admin_Login]
--           ([CNIC]
--           ,[password])
--     VALUES('35202-1908609-9','kaitoKID123')

--INSERT INTO [dbo].[pinfo]
--           ([CNIC]
--           ,[Name]
--           ,[DOB]
--           ,[Gender]
--           ,[spouse])
--     VALUES('35202-1908609-3','Umer','12-17-2001','M',NULL)
GO	

create procedure signinclient
@CNIC varchar (15),
@pass varchar (MAX),
@flag int output
As
Begin
	Declare @temp varchar(100)
	Set @flag = 1
	if exists
	(
		Select m.CNIC
		From member_Login as m
		where m.CNIC = @CNIC
	)
	begin
		Set @temp = 
		(
			Select m.password
			from member_Login as m
			where m.CNIC= @CNIC
		)
	END
	else
		set @flag = 0
	if @pass != @temp
		set @flag = 0
	
End
go
-----------------------------------------
create procedure signinadmin
@CNIC varchar (15),
@pass varchar (MAX),
@flag int output
As
Begin
	Declare @temp varchar(100)
	Set @flag = 1
	if exists
	(
		Select m.CNIC
		From admin_login as m
		where m.CNIC = @CNIC
	)
	begin
		Set @temp = 
		(
			Select m.password
			from member_Login as m
			where m.CNIC= @CNIC
		)
	END
	else
		set @flag = 0
	if @pass != @temp
		set @flag = 0
	
End
go
-----------------------------------------
create procedure addcomplain
@CNIC varchar (15),
@compaint varchar (MAX)
As
Begin
	insert into complaints values(@CNIC,@compaint,'Undone')
End
go
-----------------------------------------
go
create procedure addClient
@CNIC varchar(15),
@pass varchar(50),
@Name varchar(50),
@DOB varchar(15),
@Gen varchar,
@flag int output
as
begin
	set @flag=1
	if exists
	(
		Select m.CNIC
		From admin_login as m
		where m.CNIC = @CNIC
	)
	begin 
		set @flag=0
	end
	else
		begin
			INSERT INTO [dbo].[member_Login] ([CNIC],[password]) VALUES (@CNIC,@pass)
			INSERT INTO [dbo].[pinfo] ([CNIC],[Name],[DOB],[Gender],[spouse]) VALUES(@CNIC,@Name,@DOB,@Gen,NULL)
			set @flag=1
		end
end
go


---------------------------------------------------
create procedure viewclient
@CNIC varchar(15)
as begin 
	select admin_Login.CNIC,Name,CAST(DOB AS DATE) as 'DOB',Gender from admin_Login  join pinfo on pinfo.CNIC=admin_Login.CNIC where admin_Login.CNIC=@CNIC
end
--drop procedure viewclient

--exec viewclient @CNIC='35202-1908609-9'
---------------------------------------------------
go
create procedure addSim
@CNIC varchar(15),
@number varchar(15),
@company varchar(15),
@flag int output
as
begin
	set @flag=1
		begin try
			INSERT INTO [dbo].[sims] ([CNIC],[number],[company],[status]) VALUES (@CNIC,@number,@company,'active')
		end try
		begin catch
				set @flag=0
		end catch

end
--drop proc addSim 
go
----------------------------------------------------
create procedure statusComplete
@CNIC varchar(15),
@description varchar(max)
as
begin
	update requests set [requests].[status]='Complete' where CNIC=@CNIC and [description]=@description and [status]='Incomplete'
end
----------------------------------------------------
go 
create procedure requestCreate
@CNIC varchar(15),
@description varchar(max)
as
begin
	INSERT INTO [dbo].[requests]
           ([CNIC]
           ,[description],[status])
     VALUES(@CNIC,@description,'Incomplete')
end

----------------------------------------------------
go 
create procedure addProperty
@CNIC varchar(15),
@houseNo varchar(50),
@address varchar(100),
@city varchar(50),
@flag int output
as
begin
	set @flag=1
	if exists
	(
		Select property.CNIC
		From property
		where property.address = @address and property.house_number=@houseNo and property.city=@city
	)
	begin 
		set @flag=0
	end
	else
		begin
			INSERT INTO [dbo].property([CNIC],[house_number],[address],[city]) VALUES (@CNIC,@houseNo,@address,@city)
			set @flag=1
		end
end
----------------------------------------------------
go
create procedure addVisa
@CNIC varchar(15),
@country varchar(15),
@flag int output
as
begin
	set @flag=1
	if exists
	(
		Select CNIC
		From visa
		where CNIC = @CNIC and country=@country
	)
	begin 
		set @flag=0
	end
	else
		begin
			INSERT INTO [dbo].[visa] ([CNIC],[country]) VALUES (@CNIC,@country)
			set @flag=1
		end
end





----------------------------------------------------
go
create procedure addCar
@CNIC varchar(15),
@car varchar(50),
@plate varchar(7),
@flag int output
as
begin
	set @flag=1
	if exists
	(
		Select car.numberplate
		From car
		where car.numberplate = @plate
	)
	begin 
		set @flag=0
	end
	else
		begin
			INSERT INTO [dbo].car([CNIC],[car],[numberplate]) VALUES (@CNIC,@car,@plate)
			set @flag=1
		end
end
------------------------------------------
go
create trigger deleteAll
on member_Login
for delete
as
	begin
	declare @Cnic varchar(15)
	select @Cnic= CNIC from deleted
	print @Cnic
	delete from pinfo where CNIC=@Cnic
	delete from Vaccine where CNIC=@Cnic
	delete from visa where CNIC=@Cnic
	delete from Diseases where CNIC=@Cnic
	delete from car where CNIC=@Cnic
	delete from property where CNIC=@Cnic
	delete from sims where CNIC=@Cnic
	delete from finance where CNIC=@Cnic
	delete from complaints where CNIC=@Cnic
	delete from requests where CNIC=@Cnic
	
	delete from admin_login where CNIC=@Cnic
	--delete from member_Login where CNIC=@Cnic
	end

	--drop trigger deleteAll
--select * from pinfo
--delete from member_Login where CNIC='35202-4908609-3'
------------------------------------------
--DELETE FROM  member_Login;
--go
--DELETE FROM [Nadra].[dbo].[pinfo] where CNIC='35202-1908609-3'
--insert into member_login values('35202-1908609-9','KaitoKID123')
--insert into admin_Login values('35202-1908609-9','KaitoKID123')
--select * from member_Login
--select * from admin_Login
--select * from admin_Login  join pinfo on pinfo.CNIC=admin_Login.CNIC  where admin_Login.CNIC='35202-1908609-9' and password='kaitoKID123'
--update member_Login set password='KUCHB123' where CNIC='35202-1908609-9'
--SELECT * FROM [Nadra].[dbo].[pinfo] where CNIC='35202-1908609-9'
--SELECT * from pinfo


--select * from admin_Login inner join  pinfo on pinfo.CNIC = admin_Login.CNIC

--select * from member_Login join pinfo on pinfo.CNIC = member_Login.CNIC where member_Login.CNIC = @CNIC and password = @password
--select * from requests
