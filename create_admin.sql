-- ============================================================
-- Tạo tài khoản Admin cho EduSphere
-- Password: Admin@123456
-- BCrypt hash của "Admin@123456" với strength=12
-- ============================================================
USE [EduSphere];
GO

-- Bước 1: Thêm user admin (nếu chưa tồn tại)
IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE email = N'admin@edusphere.vn')
BEGIN
    INSERT INTO dbo.users (full_name, email, password_hash, status, created_at)
    VALUES (
        N'Quản trị viên',
        N'admin@edusphere.vn',
        -- BCrypt hash của "Admin@123456" (strength 12)
        N'$2a$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
        N'ACTIVE',
        SYSDATETIME()
    );
    PRINT 'Đã tạo user admin@edusphere.vn';
END
ELSE
BEGIN
    PRINT 'User admin@edusphere.vn đã tồn tại';
END
GO

-- Bước 2: Gán role ADMINISTRATOR (nếu chưa có)
DECLARE @userId INT = (SELECT user_id FROM dbo.users WHERE email = N'admin@edusphere.vn');
DECLARE @adminRoleId INT = (SELECT role_id FROM dbo.roles WHERE role_name = N'ADMINISTRATOR');

IF @adminRoleId IS NULL
BEGIN
    PRINT 'Lỗi: Role ADMINISTRATOR không tồn tại trong bảng roles!';
    PRINT 'Hãy chạy script SQLQuery1.sql trước để seed roles.';
END
ELSE IF NOT EXISTS (
    SELECT 1 FROM dbo.user_roles 
    WHERE user_id = @userId AND role_id = @adminRoleId
)
BEGIN
    INSERT INTO dbo.user_roles (user_id, role_id)
    VALUES (@userId, @adminRoleId);
    PRINT 'Đã gán role ADMINISTRATOR cho admin@edusphere.vn';
END
ELSE
BEGIN
    PRINT 'User đã có role ADMINISTRATOR';
END
GO

-- Kiểm tra kết quả
SELECT 
    u.user_id,
    u.full_name,
    u.email,
    u.status,
    r.role_name
FROM dbo.users u
JOIN dbo.user_roles ur ON u.user_id = ur.user_id
JOIN dbo.roles r ON ur.role_id = r.role_id
WHERE u.email = N'admin@edusphere.vn';
GO
