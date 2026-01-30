-- ============================================================================
-- Digital Notice Board System - Oracle SQL Database Schema
-- ============================================================================
-- Description: Complete database schema for the notice board system
-- Database: Oracle SQL
-- Author: Digital Notice Board System Team
-- Created: January 2026
-- ============================================================================

-- Clean up existing objects (if any) - for development only
-- DROP TABLE notices CASCADE CONSTRAINTS;
-- DROP TABLE users CASCADE CONSTRAINTS;
-- DROP TABLE roles CASCADE CONSTRAINTS;
-- DROP TABLE categories CASCADE CONSTRAINTS;
-- DROP SEQUENCE user_seq;
-- DROP SEQUENCE notice_seq;
-- DROP SEQUENCE role_seq;
-- DROP SEQUENCE category_seq;

-- ============================================================================
-- SEQUENCES FOR AUTO-INCREMENT PRIMARY KEYS
-- ============================================================================

-- Sequence for ROLES table
CREATE SEQUENCE role_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Sequence for CATEGORIES table
CREATE SEQUENCE category_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Sequence for USERS table
CREATE SEQUENCE user_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Sequence for NOTICES table
CREATE SEQUENCE notice_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- ============================================================================
-- TABLE: ROLES
-- Description: Stores user roles (Admin, Student)
-- ============================================================================

CREATE TABLE roles (
    role_id NUMBER PRIMARY KEY,
    role_name VARCHAR2(50) NOT NULL UNIQUE,
    role_description VARCHAR2(200),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_role_name CHECK (role_name IN ('Admin', 'Student'))
);

-- Add comments for documentation
COMMENT ON TABLE roles IS 'Stores user role definitions';
COMMENT ON COLUMN roles.role_id IS 'Primary key - unique role identifier';
COMMENT ON COLUMN roles.role_name IS 'Role name - Admin or Student';
COMMENT ON COLUMN roles.role_description IS 'Description of role permissions';

-- ============================================================================
-- TABLE: CATEGORIES
-- Description: Stores notice categories
-- ============================================================================

CREATE TABLE categories (
    category_id NUMBER PRIMARY KEY,
    category_name VARCHAR2(50) NOT NULL UNIQUE,
    category_description VARCHAR2(200),
    display_color VARCHAR2(7),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_category_name CHECK (
        category_name IN ('Exam', 'Event', 'Emergency', 'General', 'Academic', 'Placement')
    )
);

-- Add comments for documentation
COMMENT ON TABLE categories IS 'Stores notice category definitions';
COMMENT ON COLUMN categories.category_id IS 'Primary key - unique category identifier';
COMMENT ON COLUMN categories.category_name IS 'Category name (Exam, Event, Emergency, General, Academic, Placement)';
COMMENT ON COLUMN categories.display_color IS 'Hex color code for UI display';

-- ============================================================================
-- TABLE: USERS
-- Description: Stores user account information
-- ============================================================================

CREATE TABLE users (
    user_id NUMBER PRIMARY KEY,
    username VARCHAR2(50) NOT NULL UNIQUE,
    password_hash VARCHAR2(255) NOT NULL,
    full_name VARCHAR2(100) NOT NULL,
    email VARCHAR2(100) NOT NULL UNIQUE,
    role_id NUMBER NOT NULL,
    is_active NUMBER(1) DEFAULT 1,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_role FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE,
    CONSTRAINT chk_is_active CHECK (is_active IN (0, 1)),
    CONSTRAINT chk_email_format CHECK (REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$'))
);

-- Add comments for documentation
COMMENT ON TABLE users IS 'Stores user account information for authentication and authorization';
COMMENT ON COLUMN users.user_id IS 'Primary key - unique user identifier';
COMMENT ON COLUMN users.username IS 'Unique username for login';
COMMENT ON COLUMN users.password_hash IS 'Hashed password (never store plain text)';
COMMENT ON COLUMN users.full_name IS 'Full name of the user';
COMMENT ON COLUMN users.email IS 'Unique email address';
COMMENT ON COLUMN users.role_id IS 'Foreign key to roles table';
COMMENT ON COLUMN users.is_active IS 'Account status: 1=active, 0=inactive';

-- ============================================================================
-- TABLE: NOTICES
-- Description: Stores all notice information
-- ============================================================================

CREATE TABLE notices (
    notice_id NUMBER PRIMARY KEY,
    title VARCHAR2(200) NOT NULL,
    description CLOB NOT NULL,
    category_id NUMBER NOT NULL,
    priority VARCHAR2(20) NOT NULL,
    created_by NUMBER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    status VARCHAR2(20) DEFAULT 'Active',
    view_count NUMBER DEFAULT 0,
    is_deleted NUMBER(1) DEFAULT 0,
    CONSTRAINT fk_notice_category FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE CASCADE,
    CONSTRAINT fk_notice_creator FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT chk_priority CHECK (priority IN ('High', 'Medium', 'Low')),
    CONSTRAINT chk_status CHECK (status IN ('Active', 'Expired', 'Draft')),
    CONSTRAINT chk_is_deleted CHECK (is_deleted IN (0, 1)),
    CONSTRAINT chk_expiry_date CHECK (expires_at > created_at)
);

-- Add comments for documentation
COMMENT ON TABLE notices IS 'Stores all notice information and metadata';
COMMENT ON COLUMN notices.notice_id IS 'Primary key - unique notice identifier';
COMMENT ON COLUMN notices.title IS 'Notice title/heading';
COMMENT ON COLUMN notices.description IS 'Full notice description/content';
COMMENT ON COLUMN notices.category_id IS 'Foreign key to categories table';
COMMENT ON COLUMN notices.priority IS 'Priority level: High, Medium, or Low';
COMMENT ON COLUMN notices.created_by IS 'Foreign key to users table (admin who created notice)';
COMMENT ON COLUMN notices.expires_at IS 'Expiration date/time of the notice';
COMMENT ON COLUMN notices.status IS 'Current status: Active, Expired, or Draft';
COMMENT ON COLUMN notices.view_count IS 'Number of times notice has been viewed';
COMMENT ON COLUMN notices.is_deleted IS 'Soft delete flag: 0=not deleted, 1=deleted';

-- ============================================================================
-- INDEXES FOR PERFORMANCE OPTIMIZATION
-- ============================================================================

-- Index on users table for login lookup
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role_id);

-- Indexes on notices table for common queries
CREATE INDEX idx_notices_category ON notices(category_id);
CREATE INDEX idx_notices_priority ON notices(priority);
CREATE INDEX idx_notices_status ON notices(status);
CREATE INDEX idx_notices_created_by ON notices(created_by);
CREATE INDEX idx_notices_created_at ON notices(created_at DESC);
CREATE INDEX idx_notices_expires_at ON notices(expires_at);

-- Composite index for active notices ordered by priority and date
CREATE INDEX idx_notices_active_priority ON notices(status, priority, created_at DESC);

-- Index for soft delete queries
CREATE INDEX idx_notices_is_deleted ON notices(is_deleted);

-- ============================================================================
-- TRIGGERS FOR AUTOMATED TASKS
-- ============================================================================

-- Trigger to automatically update 'updated_at' timestamp on USERS table
CREATE OR REPLACE TRIGGER trg_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
BEGIN
    :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

-- Trigger to automatically update 'updated_at' timestamp on NOTICES table
CREATE OR REPLACE TRIGGER trg_notices_updated_at
BEFORE UPDATE ON notices
FOR EACH ROW
BEGIN
    :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

-- Trigger to automatically set notice status to 'Expired' when expiry date passes
CREATE OR REPLACE TRIGGER trg_notices_auto_expire
BEFORE INSERT OR UPDATE ON notices
FOR EACH ROW
BEGIN
    IF :NEW.expires_at < CURRENT_TIMESTAMP AND :NEW.status = 'Active' THEN
        :NEW.status := 'Expired';
    END IF;
END;
/

-- ============================================================================
-- VIEWS FOR COMMON QUERIES
-- ============================================================================

-- View: Active notices with full details
CREATE OR REPLACE VIEW vw_active_notices AS
SELECT 
    n.notice_id,
    n.title,
    n.description,
    c.category_name,
    c.display_color AS category_color,
    n.priority,
    u.full_name AS created_by_name,
    u.username AS created_by_username,
    n.created_at,
    n.updated_at,
    n.expires_at,
    n.status,
    n.view_count,
    CASE 
        WHEN n.priority = 'High' THEN 1
        WHEN n.priority = 'Medium' THEN 2
        WHEN n.priority = 'Low' THEN 3
    END AS priority_order
FROM notices n
INNER JOIN categories c ON n.category_id = c.category_id
INNER JOIN users u ON n.created_by = u.user_id
WHERE n.status = 'Active' 
  AND n.is_deleted = 0
  AND n.expires_at > CURRENT_TIMESTAMP
ORDER BY priority_order, n.created_at DESC;

-- View: Notice statistics by category
CREATE OR REPLACE VIEW vw_notice_stats_by_category AS
SELECT 
    c.category_name,
    COUNT(n.notice_id) AS total_notices,
    SUM(CASE WHEN n.status = 'Active' THEN 1 ELSE 0 END) AS active_notices,
    SUM(CASE WHEN n.status = 'Expired' THEN 1 ELSE 0 END) AS expired_notices,
    SUM(CASE WHEN n.priority = 'High' THEN 1 ELSE 0 END) AS high_priority_count,
    SUM(n.view_count) AS total_views
FROM categories c
LEFT JOIN notices n ON c.category_id = n.category_id AND n.is_deleted = 0
GROUP BY c.category_name
ORDER BY c.category_name;

-- View: User activity summary
CREATE OR REPLACE VIEW vw_user_activity AS
SELECT 
    u.user_id,
    u.username,
    u.full_name,
    r.role_name,
    u.last_login,
    COUNT(n.notice_id) AS notices_created,
    u.is_active
FROM users u
INNER JOIN roles r ON u.role_id = r.role_id
LEFT JOIN notices n ON u.user_id = n.created_by AND n.is_deleted = 0
GROUP BY u.user_id, u.username, u.full_name, r.role_name, u.last_login, u.is_active
ORDER BY u.username;

-- ============================================================================
-- STORED PROCEDURES
-- ============================================================================

-- Procedure to create a new notice
CREATE OR REPLACE PROCEDURE sp_create_notice (
    p_title IN VARCHAR2,
    p_description IN CLOB,
    p_category_name IN VARCHAR2,
    p_priority IN VARCHAR2,
    p_created_by IN NUMBER,
    p_expires_at IN TIMESTAMP,
    p_notice_id OUT NUMBER
) AS
    v_category_id NUMBER;
BEGIN
    -- Get category_id from category_name
    SELECT category_id INTO v_category_id
    FROM categories
    WHERE category_name = p_category_name;
    
    -- Get next sequence value
    SELECT notice_seq.NEXTVAL INTO p_notice_id FROM DUAL;
    
    -- Insert the notice
    INSERT INTO notices (
        notice_id, title, description, category_id, 
        priority, created_by, expires_at
    ) VALUES (
        p_notice_id, p_title, p_description, v_category_id,
        p_priority, p_created_by, p_expires_at
    );
    
    COMMIT;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Category not found: ' || p_category_name);
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END sp_create_notice;
/

-- Procedure to soft delete a notice
CREATE OR REPLACE PROCEDURE sp_delete_notice (
    p_notice_id IN NUMBER
) AS
BEGIN
    UPDATE notices
    SET is_deleted = 1,
        status = 'Expired',
        updated_at = CURRENT_TIMESTAMP
    WHERE notice_id = p_notice_id;
    
    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Notice not found: ' || p_notice_id);
    END IF;
    
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END sp_delete_notice;
/

-- Procedure to increment view count
CREATE OR REPLACE PROCEDURE sp_increment_view_count (
    p_notice_id IN NUMBER
) AS
BEGIN
    UPDATE notices
    SET view_count = view_count + 1
    WHERE notice_id = p_notice_id
      AND is_deleted = 0;
    
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END sp_increment_view_count;
/

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- Function to get active notice count
CREATE OR REPLACE FUNCTION fn_get_active_notice_count
RETURN NUMBER
IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM notices
    WHERE status = 'Active'
      AND is_deleted = 0
      AND expires_at > CURRENT_TIMESTAMP;
    
    RETURN v_count;
END fn_get_active_notice_count;
/

-- Function to check if user is admin
CREATE OR REPLACE FUNCTION fn_is_admin (
    p_user_id IN NUMBER
) RETURN NUMBER
IS
    v_is_admin NUMBER;
BEGIN
    SELECT CASE WHEN r.role_name = 'Admin' THEN 1 ELSE 0 END
    INTO v_is_admin
    FROM users u
    INNER JOIN roles r ON u.role_id = r.role_id
    WHERE u.user_id = p_user_id;
    
    RETURN v_is_admin;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
END fn_is_admin;
/

-- ============================================================================
-- GRANT PERMISSIONS (adjust according to your database users)
-- ============================================================================

-- Example: Grant permissions to application user (uncomment and modify as needed)
-- GRANT SELECT, INSERT, UPDATE, DELETE ON roles TO app_user;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON categories TO app_user;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON users TO app_user;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON notices TO app_user;
-- GRANT SELECT ON vw_active_notices TO app_user;
-- GRANT SELECT ON vw_notice_stats_by_category TO app_user;
-- GRANT SELECT ON vw_user_activity TO app_user;
-- GRANT EXECUTE ON sp_create_notice TO app_user;
-- GRANT EXECUTE ON sp_delete_notice TO app_user;
-- GRANT EXECUTE ON sp_increment_view_count TO app_user;
-- GRANT EXECUTE ON fn_get_active_notice_count TO app_user;
-- GRANT EXECUTE ON fn_is_admin TO app_user;

-- ============================================================================
-- END OF SCHEMA CREATION
-- ============================================================================

-- Display completion message
BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================');
    DBMS_OUTPUT.PUT_LINE('Database schema created successfully!');
    DBMS_OUTPUT.PUT_LINE('============================================');
    DBMS_OUTPUT.PUT_LINE('Tables created: ROLES, CATEGORIES, USERS, NOTICES');
    DBMS_OUTPUT.PUT_LINE('Sequences created: 4');
    DBMS_OUTPUT.PUT_LINE('Indexes created: 11');
    DBMS_OUTPUT.PUT_LINE('Triggers created: 3');
    DBMS_OUTPUT.PUT_LINE('Views created: 3');
    DBMS_OUTPUT.PUT_LINE('Stored Procedures created: 3');
    DBMS_OUTPUT.PUT_LINE('Functions created: 2');
    DBMS_OUTPUT.PUT_LINE('============================================');
    DBMS_OUTPUT.PUT_LINE('Next step: Run sample_data.sql to insert test data');
    DBMS_OUTPUT.PUT_LINE('============================================');
END;
/
