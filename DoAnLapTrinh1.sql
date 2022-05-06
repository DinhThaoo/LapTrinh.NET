CREATE DATABASE DoAnLapTrinh;

--Tài khoản
--Nhân sự
--Khách hàng
--Nhà cung cấp
--Nguyên liệu
--Phiếu xuất
--Phiếu nhập
--Loại sản phẩm
--Sản phẩm
--Công thức
--Bàn
--Hoá đơn
--Chi tiết hoá đơn
--Báo cáo thống kê

INSERT INTO KhachHang(HoTen, SDT) VALUES (N'Nguyễn Văn A', 0123)

CREATE TABLE TaiKhoan
(
    TenDangNhap nvarchar(100) primary key,
	TenHienThi nvarchar(100) not null default N'Administrator',
	MatKhau nvarchar(1000) not null default 0,
	LoaiTaiKhoan int not null default 0 --Staff-0/Admin-1
);

CREATE TABLE NhanSu
(
    MaNhanSu int identity primary key,
	HoTen nvarchar(100) not null default N'Coffee Name',
	GioiTinh nvarchar(50),
	NgaySinh date,
	CMND nvarchar(50) not null,
	ViTri nvarchar(50), --Quản lý(2)/Nhân viên lễ tân(2)/Nhân viên kế toán(1)/Nhân viên phục vụ(4)/Nhân viên pha chế(2)/Nhân viên làm bánh(2)/Nhân viên bảo vệ(2)
	TrangThai nvarchar(50) not null default N'Thực tập', --Nhân viên chính thức/Thực tập/Đã nghỉ
	ThoiGianVaoLam date not null,
	SoNgayCong int not null,
	LuongThang float not null
);

CREATE TABLE NhaCungCap
(
	MaNhaCungCap int identity primary key,
	TenNhaCungCap nvarchar(100) not null default N'Chưa đặt tên',
	SDT int not null,
	Email nvarchar(100) not null default N'@gmail.com',
	DiaChi nvarchar(100) not null,
	TrangThai nvarchar(100), --Trao đổi/Ngưng
);

CREATE TABLE LoaiSanPham
(
	MaLoai int identity primary key,
	TenLoai nvarchar(100) not null default N'Chưa đặt tên',
);

CREATE TABLE SanPham
(
	MaSanPham int identity primary key,
	TenSanPham nvarchar(100) not null default N'Chưa đặt tên',
	MaLoai int not null,
	SoLuong int, -- Tự nhập
	GiaBan float not null default 0,
);

CREATE TABLE CongThuc
(
	MaCongThuc int identity primary key,
	MaSanPham int,
	MaNguyenLieu int,
	UocLuongSLTP int
);

CREATE TABLE Ban
(
	MaBan int identity primary key,
	TenBan nvarchar(100) not null default N'Chưa đặt tên',
	TrangThai nvarchar(100) not null default N'Trống', --Bàn trống-0/Đã có người-1
);


CREATE TABLE BaoCaoThongKe
(
	MaBaoCao int identity primary key,
	ThoiGian nvarchar(100), --Tháng/Năm
	MaNhanSu int
);

DELETE FROM HoaDon WHERE MaHoaDon = 10
-----------------KHÁCH HÀNG --------------------------------

CREATE TABLE KhachHang --4 bảng trong C#: Tất cả khách hàng, Khách thường, Khách quen, Khách Vip
(
    MaKhachHang int identity primary key,
	HoTen nvarchar(100) not null default N'Coffee Name',
	SDT int not null,
	SoHoaDon int default 0, --Số lần sử dụng dịch vụ tại quán
	TongSoTien float default 0,
	TrangThai nvarchar(100) default N'Bạc', --Số hoá đơn <3: Khách 'Bạc', Số hoá đơn >2 và <8: Khách 'Vàng', Số hoá đơn >7: Khách 'Kim cương'
	TichDiem int default 0, --1 lần sử dụng dịch vụ tại quán = 5 điểm
	DoiDiem float default 0, --Số điểm nhân 100, về sau sử dụng dịch vụ tiếp sẽ lấy số tiền - đổi điểm = tiền thanh toán
);


EXEC TichDiem
EXEC DoiDiem

CREATE PROC KhachBac
AS
    UPDATE KhachHang
	SET TrangThai = N'Bạc'
    WHERE SoHoaDon<3
GO

CREATE PROC KhachVang
AS
    UPDATE KhachHang
	SET TrangThai = N'Vàng'
    WHERE SoHoaDon<8 and SoHoaDon>2;
GO

CREATE PROC KhachKimCuong
AS
    UPDATE KhachHang
	SET TrangThai = N'Kim cương'
    WHERE SoHoaDon>7;
GO

CREATE PROC TichDiem
AS
    UPDATE KhachHang
	SET TichDiem = SoHoaDon*5
GO

CREATE PROC DoiDiem
AS
    UPDATE KhachHang
	SET DoiDiem = TichDiem*100
GO


CREATE TRIGGER SoHoaDon ON HoaDon
FOR UPDATE, INSERT
AS
UPDATE KhachHang
SET SoHoaDon = (SELECT COUNT(MaHoaDon)
				FROM HoaDon
                WHERE HoaDon.MaKhachHang = KhachHang.MaKhachHang
				GROUP BY MaKhachHang)

-------------------------------------------------
CREATE PROC TongSoTien
AS
    UPDATE KhachHang
	SET TongSoTien = (SELECT sum(TongTien)
                      FROM HoaDon
                      WHERE HoaDon.MaKhachHang = KhachHang.MaKhachHang)
    WHERE MaKhachHang = MaKhachHang;
GO

EXEC TongSoTien; 
-------------------------------------------------


--------------------------- NGUYÊN LIỆU ---------------------------------
CREATE TABLE NguyenLieu
(
	MaNguyenLieu int identity primary key,
	MaNhaCungCap int not null,
	TenNguyenLieu nvarchar(100) not null default N'Nguyên liệu',
	SoLuongTonKho int,
	GiaNhap float not null default 0
);
-------------------------------------------------
CREATE PROC Nhap_NLC
AS
    UPDATE NguyenLieu
	SET SoLuongTonKho =  SoLuongTonKho + SoLuong
    FROM NguyenLieu, PhieuNhap
	WHERE NguyenLieu.MaNguyenLieu = PhieuNhap.MaNguyenLieu
GO
EXEC Nhap_NLC; 

-------------------------------------------------
CREATE PROC Xuat_NLC
AS
    UPDATE NguyenLieu
	SET SoLuongTonKho =  SoLuongTonKho - SoLuong
    FROM NguyenLieu, PhieuXuat
	WHERE NguyenLieu.MaNguyenLieu = PhieuXuat.MaNguyenLieu
GO
EXEC Xuat_NLC;
Select * From NguyenLieu


-------------------------------------------------
CREATE PROC SoLuongTKNhap
AS
    UPDATE NguyenLieu
	SET SoLuongTonKho = (SELECT SoLuongTonKho + SoLuong
                      FROM NguyenLieu, PhieuNhap
                      WHERE PhieuNhap.MaNguyenLieu = NguyenLieu.MaNguyenLieu)
    WHERE MaNguyenLieu = MaNguyenLieu;
GO
EXEC SoLuongTKNhap; 
-------------------------------------------------



---------------------PHIẾU XUẤT ----------------------------
CREATE TABLE PhieuXuat
(
	MaPhieuXuat int identity primary key,
	MaNguyenLieu int not null,
	SoLuong int not null,
	Gia float, -- Giá = Số lượng * giá nhập (Bảng Nguyên Liệu)
	NgayXuat date not null
);

-------------------------------------------------
-- Giá (Bảng phiếu xuất) = Số lượng * giá nhập (Bảng nguyên liệu)

CREATE PROC GiaPhieuXuat2
AS
    UPDATE PhieuXuat
	SET Gia = (SELECT SoLuong * GiaNhap
                      FROM NguyenLieu
                      WHERE PhieuXuat.MaNguyenLieu = NguyenLieu.MaNguyenLieu)
    WHERE MaNguyenLieu = MaNguyenLieu;
GO
EXEC GiaPhieuXuat2;



-------------------PHIẾU NHẬP ------------------------------
CREATE TABLE PhieuNhap
(
	MaPhieuNhap int identity primary key,
	MaNhaCungCap int not null,
	MaNguyenLieu int not null,
	SoLuong int not null,
	GiaNhap float,
	NgayNhap date not null
);

------------------------------------------------
CREATE PROC CapNhatGiaNhapNguyenLieu
AS
    UPDATE PhieuNhap
	SET PhieuNhap.GiaNhap = NguyenLieu.GiaNhap
	FROM NguyenLieu
	INNER JOIN PhieuNhap
	ON (NguyenLieu.MaNguyenLieu = PhieuNhap.MaNguyenLieu)
GO

EXEC CapNhatGiaNhapNguyenLieu;

SELECT* 
FROM NguyenLieu;

--------------------------------
CREATE PROC CapNhatNhaCungCap
AS
    UPDATE PhieuNhap
	SET PhieuNhap.MaNhaCungCap = NguyenLieu.MaNhaCungCap
	FROM NguyenLieu
	INNER JOIN PhieuNhap
	ON (NguyenLieu.MaNguyenLieu = PhieuNhap.MaNguyenLieu)
GO

EXEC CapNhatNhaCungCap


--------------------HÓA ĐƠN -----------------------------
CREATE TABLE HoaDon
(
	MaHoaDon int identity primary key,
	MaNhanVien int,
	MaKhachHang int,
	MaBan int,
	ThoiGianBatDau datetime not null default getdate(),
	ThoiGianKetThuc datetime,
	TrangThai int not null default 0, --Chưa thang toán-0/Đã thanh toán-1
	TongTien float, -- Tổng tiền bằng sum(thành tiền)
);

-------------------------------------------------
CREATE PROC TongTienHoaDon
AS
    UPDATE HoaDon
	SET TongTien = (SELECT SUM(TongTien)
                      FROM CTHoaDon
                      WHERE CTHoaDon.MaHoaDon = HoaDon.MaHoaDon)
    WHERE MaHoaDon = MaHoaDon;
GO

EXEC TongTienHoaDon;


------------------

---------------------CHI TIẾT HÓA ĐƠN ----------------------------
CREATE TABLE CTHoaDon
(
	MaCTHoaDon int identity primary key,
	MaHoaDon int not null,
	MaSanPham int not null,
	SoLuong int not null default 0,
	ThanhTien float, -- Thành tiền = Số lượng * Giá bán (Sản phẩm)
);


ALTER TABLE CTHoaDon 
  ADD CONSTRAINT XoaHD_CTHD 
  FOREIGN KEY (MaHoaDon) 
  REFERENCES HoaDon(MaHoaDon) 
ON DELETE CASCADE;

-----------------------------------
CREATE PROC CapNhatGiaCTHoaDon
AS
    UPDATE CTHoaDon
	SET CTHoaDon.GiaBan = SanPham.GiaBan
	FROM CTHoaDon
	INNER JOIN SanPham
	ON (CTHoaDon.MaSanPham = SanPham.MaSanPham)
GO
EXEC CapNhatGiaCTHoaDon


ALTER TABLE HoaDon
  ADD CONSTRAINT XoaHoaDonTheoKH
  FOREIGN KEY (MaKhachHang) 
  REFERENCES KhachHang(MaKhachHang) 
ON DELETE CASCADE;

-------------------------------------------------
CREATE PROC ThanhTien
AS
    UPDATE CTHoaDon 
	SET ThanhTien = SoLuong * GiaBan
GO
EXEC ThanhTien

DELETE FROM HoaDon WHERE MaHoaDon = 11

-----------------THỐNG KÊ NHẬP XUẤT --------------------------------

CREATE TABLE ThongKeNhapXuat
(
	MaNhapXuat int identity primary key,
	MaBaoCao int,
	MaNguyenLieu int,
	Nhap int, -- Nhập tay
	Xuat int, -- Nhập tay
	SoLuongCon int -- Bằng với số lượng bảng nguyên liệu -- Để đối soát xem Nhập - Xuất có bằng số lượng còn => Thống kê đúng
);

ALTER TABLE ThongKeNhapXuat 
  ADD CONSTRAINT XoaNhapXuat
  FOREIGN KEY (MaBaoCao) 
  REFERENCES BaoCaoThongKe(MaBaoCao) 
ON DELETE CASCADE;

-------------------------------------------------
CREATE PROC CNSLCNhapXuat
AS
    UPDATE ThongKeNhapXuat
	SET SoLuongCon = (SELECT (NguyenLieu.SoLuongTonKho + PhieuNhap.SoLuong - PhieuXuat.SoLuong) as Tinh
                      FROM NguyenLieu, PhieuNhap, PhieuXuat
                      WHERE NguyenLieu.MaNguyenLieu = PhieuNhap.MaNguyenLieu AND NguyenLieu.MaNguyenLieu = PhieuXuat.MaNguyenLieu)
    WHERE MaNguyenLieu = MaNguyenLieu;
GO
EXEC CNSLCNhapXuat;
SELECT * FROM ThongKeNhapXuat

-------------------------------------------------
CREATE PROC SoLuongConNhapXuat
AS
    UPDATE ThongKeNhapXuat
	SET ThongKeNhapXuat.SoLuongCon = NguyenLieu.SoLuongTonKho
	FROM ThongKeNhapXuat
	INNER JOIN NguyenLieu
	ON (ThongKeNhapXuat.MaNguyenLieu = NguyenLieu.MaNguyenLieu)
GO
EXEC SoLuongConNhapXuat;

-------------------------------------------------

CREATE PROC Nhap
AS
    UPDATE ThongKeNhapXuat
	SET Nhap = (SELECT SUM(SoLuong)
				FROM PhieuNhap)
GO
EXEC Nhap;

select* FROM ThongKeNhapXuat
-------------------------------------------------

CREATE PROC Xuat
AS
    UPDATE ThongKeNhapXuat
	SET Xuat = (SELECT SUM(SoLuong)
				FROM PhieuXuat)
GO
EXEC Xuat;

------------------THỐNG KÊ THI CHI -------------------------------

CREATE TABLE ThongKeThuChi
(
	MaThuChi int identity primary key,
	MaBaoCao int,
	SoTienChi float, -- Nhập tay tổng số tiền của phiếu xuất
	SoTienThu float, -- Nhập tay tổng số tiền của hoá đơn
	TongLuongNhanVien float, -- Nhập tay tổng số lương nhân viên
	SoTienLai float -- Tiền lãi = Tiền thu - tiền chi - Lương nhân viên
);

ALTER TABLE ThongKeThuChi
  ADD CONSTRAINT XoaThuChi
  FOREIGN KEY (MaBaoCao) 
  REFERENCES BaoCaoThongKe(MaBaoCao) 
ON DELETE CASCADE;

-------------------------------
CREATE PROC TienChi
AS
    UPDATE ThongKeThuChi
	SET SoTienChi = (SELECT SUM(PhieuXuat.Gia)
							FROM PhieuXuat)
GO
EXEC TienChi;
SELECT * FROM ThongKeThuChi


------------------------------------------
CREATE PROC TienThu
AS
    UPDATE ThongKeThuChi
	SET SoTienThu = (SELECT SUM(TongTien)
							FROM HoaDon)
GO
EXEC TienThu;
SELECT * FROM ThongKeThuChi


--------------------------------------
CREATE PROC TongLuongNV
AS
    UPDATE ThongKeThuChi
	SET TongLuongNhanVien = (SELECT SUM(LuongThang)
							FROM NhanSu)
GO
EXEC TongLuongNV;
SELECT * FROM ThongKeThuChi

-------------------------------------------------
CREATE PROC TienLai
AS
    UPDATE ThongKeThuChi
	SET SoTienLai = SoTienThu - SoTienChi - TongLuongNhanVien
GO
EXEC TienLai;
SELECT * FROM ThongKeThuChi



--------------------THỐNG KÊ DOANN THU BÁN  HÀNG -----------------------------
CREATE PROC CapNhatSoHoaDon
AS
    UPDATE KhachHang
	SET SoHoaDon = (SELECT sum(MaHoaDon)
                      FROM HoaDon
                      WHERE HoaDon.MaKhachHang = KhachHang.MaKhachHang)
    WHERE MaKhachHang = MaKhachHang;
GO

EXEC CapNhatSoHoaDon;






