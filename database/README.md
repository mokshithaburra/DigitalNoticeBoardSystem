# Database Schema Documentation

This directory contains the Oracle SQL database schema and sample data for the Digital Notice Board System.

## 📁 Files

- **schema.sql** - Complete database schema with tables, indexes, triggers, views, and procedures
- **sample_data.sql** - Sample/test data for development and testing
- **README.md** - This file

## 🗄️ Database Structure

### Tables

#### 1. ROLES
Stores user role definitions (Admin, Student)

| Column | Type | Description |
|--------|------|-------------|
| role_id | NUMBER | Primary key |
| role_name | VARCHAR2(50) | Role name (Admin/Student) |
| role_description | VARCHAR2(200) | Role description |
| created_at | TIMESTAMP | Creation timestamp |

#### 2. CATEGORIES
Stores notice category definitions

| Column | Type | Description |
|--------|------|-------------|
| category_id | NUMBER | Primary key |
| category_name | VARCHAR2(50) | Category name |
| category_description | VARCHAR2(200) | Category description |
| display_color | VARCHAR2(7) | Hex color code for UI |
| created_at | TIMESTAMP | Creation timestamp |

**Categories:**
- Exam
- Event
- Emergency
- General
- Academic
- Placement

#### 3. USERS
Stores user account information

| Column | Type | Description |
|--------|------|-------------|
| user_id | NUMBER | Primary key |
| username | VARCHAR2(50) | Unique username |
| password_hash | VARCHAR2(255) | Hashed password |
| full_name | VARCHAR2(100) | Full name |
| email | VARCHAR2(100) | Email address |
| role_id | NUMBER | Foreign key to ROLES |
| is_active | NUMBER(1) | Account status (1=active, 0=inactive) |
| last_login | TIMESTAMP | Last login timestamp |
| created_at | TIMESTAMP | Account creation timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

#### 4. NOTICES
Stores all notice information

| Column | Type | Description |
|--------|------|-------------|
| notice_id | NUMBER | Primary key |
| title | VARCHAR2(200) | Notice title |
| description | CLOB | Notice description/content |
| category_id | NUMBER | Foreign key to CATEGORIES |
| priority | VARCHAR2(20) | Priority (High/Medium/Low) |
| created_by | NUMBER | Foreign key to USERS |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Last update timestamp |
| expires_at | TIMESTAMP | Expiration timestamp |
| status | VARCHAR2(20) | Status (Active/Expired/Draft) |
| view_count | NUMBER | Number of views |
| is_deleted | NUMBER(1) | Soft delete flag |

### Relationships

```
ROLES (1) ────< (M) USERS
CATEGORIES (1) ────< (M) NOTICES
USERS (1) ────< (M) NOTICES (via created_by)
```

### Indexes

Performance indexes created on:
- Users: username, email, role_id
- Notices: category_id, priority, status, created_by, created_at, expires_at
- Composite index on active notices (status, priority, created_at)

### Views

#### vw_active_notices
Returns all active, non-expired notices with full details including:
- Category information
- Creator information
- Priority ordering

#### vw_notice_stats_by_category
Provides statistics for each category:
- Total notices
- Active/expired counts
- Priority distribution
- Total views

#### vw_user_activity
Shows user activity summary:
- User details
- Role information
- Number of notices created
- Last login time

### Stored Procedures

#### sp_create_notice
Creates a new notice with all required parameters.

**Parameters:**
- p_title (IN VARCHAR2)
- p_description (IN CLOB)
- p_category_name (IN VARCHAR2)
- p_priority (IN VARCHAR2)
- p_created_by (IN NUMBER)
- p_expires_at (IN TIMESTAMP)
- p_notice_id (OUT NUMBER)

#### sp_delete_notice
Soft deletes a notice (sets is_deleted=1).

**Parameters:**
- p_notice_id (IN NUMBER)

#### sp_increment_view_count
Increments the view count for a notice.

**Parameters:**
- p_notice_id (IN NUMBER)

### Functions

#### fn_get_active_notice_count
Returns the count of active, non-expired notices.

**Returns:** NUMBER

#### fn_is_admin
Checks if a user has admin role.

**Parameters:**
- p_user_id (IN NUMBER)

**Returns:** NUMBER (1=admin, 0=not admin)

### Triggers

#### trg_users_updated_at
Automatically updates the `updated_at` timestamp when a user record is modified.

#### trg_notices_updated_at
Automatically updates the `updated_at` timestamp when a notice is modified.

#### trg_notices_auto_expire
Automatically sets notice status to 'Expired' if the expiry date has passed.

## 🚀 Installation Instructions

### Prerequisites
- Oracle Database 11g or higher
- SQL*Plus or Oracle SQL Developer
- Appropriate database permissions

### Step 1: Create Database Schema

Connect to your Oracle database and run the schema script:

```sql
-- Using SQL*Plus
sqlplus username/password@database
@schema.sql

-- Or using SQL Developer
-- Open schema.sql and execute (F5)
```

### Step 2: Load Sample Data (Optional)

Load sample data for testing:

```sql
@sample_data.sql
```

### Step 3: Verify Installation

Check that all objects were created:

```sql
-- Check tables
SELECT table_name FROM user_tables 
WHERE table_name IN ('ROLES', 'CATEGORIES', 'USERS', 'NOTICES');

-- Check sequences
SELECT sequence_name FROM user_sequences;

-- Check views
SELECT view_name FROM user_views 
WHERE view_name LIKE 'VW_%';

-- Check procedures
SELECT object_name FROM user_procedures 
WHERE object_type = 'PROCEDURE';
```

## 📊 Sample Data

After running `sample_data.sql`, you'll have:

### Test Credentials

**Admin Account:**
- Username: `admin`
- Password: `admin123`
- Full Name: System Administrator
- Email: admin@noticeboard.edu

**Student Account:**
- Username: `student`
- Password: `student123`
- Full Name: Test Student
- Email: student@noticeboard.edu

### Sample Notices
- 10 sample notices across all categories
- Different priority levels (High, Medium, Low)
- Mix of active and expired notices
- View counts to simulate usage

## 🔐 Security Considerations

### Password Storage
- **⚠️ IMPORTANT:** SHA-256 hashes used in sample data are FOR TESTING ONLY
- **Never store plain text passwords**
- **Production Requirement:** Use proper password hashing algorithms:
  - bcrypt (recommended)
  - scrypt
  - Argon2
- These algorithms are specifically designed for password storage with built-in salting
- SHA-256/SHA-512 are NOT secure for passwords (too fast, no salt)
- Implement individual salts per password

### Recommended Security Enhancements
1. **Use parameterized queries/bind variables** to prevent SQL injection (NEVER concatenate user input into SQL)
2. **Implement password complexity requirements** (minimum length, special characters)
3. **Add account lockout** after failed login attempts
4. **Enable audit logging** for sensitive operations
5. **Regularly backup** the database
6. **Use SSL/TLS** for database connections
7. **Implement session management** with timeouts
8. **Add two-factor authentication** for admin accounts

## 📝 Common Queries

### Get all active notices ordered by priority
```sql
SELECT * FROM vw_active_notices;
```

### Get notices by category
```sql
SELECT n.notice_id, n.title, n.priority, n.created_at
FROM notices n
JOIN categories c ON n.category_id = c.category_id
WHERE c.category_name = 'Exam'
  AND n.status = 'Active'
  AND n.is_deleted = 0
ORDER BY n.priority, n.created_at DESC;
```

### Create a new notice
```sql
DECLARE
    v_notice_id NUMBER;
BEGIN
    sp_create_notice(
        p_title => 'New Notice Title',
        p_description => 'Notice description goes here',
        p_category_name => 'General',
        p_priority => 'Medium',
        p_created_by => 1, -- User ID
        p_expires_at => TO_TIMESTAMP('2026-12-31 23:59:59', 'YYYY-MM-DD HH24:MI:SS'),
        p_notice_id => v_notice_id
    );
    DBMS_OUTPUT.PUT_LINE('Notice created with ID: ' || v_notice_id);
END;
/
```

### Authenticate user
```sql
-- SECURE APPROACH: Use bind variables to prevent SQL injection
SELECT u.user_id, u.username, u.full_name, r.role_name
FROM users u
JOIN roles r ON u.role_id = r.role_id
WHERE u.username = :username
  AND u.password_hash = :password_hash
  AND u.is_active = 1;

-- Example with actual values (for development/testing only):
-- Replace :username with 'admin'
-- Replace :password_hash with '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9'
```

### Get notice statistics
```sql
SELECT * FROM vw_notice_stats_by_category;
```

## 🔄 Maintenance

### Update expired notices
```sql
UPDATE notices
SET status = 'Expired'
WHERE expires_at < CURRENT_TIMESTAMP
  AND status = 'Active'
  AND is_deleted = 0;
COMMIT;
```

### Clean up old expired notices (optional)
```sql
-- Mark notices older than 6 months as deleted
UPDATE notices
SET is_deleted = 1
WHERE status = 'Expired'
  AND expires_at < ADD_MONTHS(CURRENT_TIMESTAMP, -6);
COMMIT;
```

### Rebuild indexes (periodic maintenance)
```sql
ALTER INDEX idx_notices_category REBUILD;
ALTER INDEX idx_notices_priority REBUILD;
ALTER INDEX idx_notices_status REBUILD;
-- Rebuild other indexes as needed
```

## 📈 Performance Optimization

### Analyze tables periodically
```sql
ANALYZE TABLE roles COMPUTE STATISTICS;
ANALYZE TABLE categories COMPUTE STATISTICS;
ANALYZE TABLE users COMPUTE STATISTICS;
ANALYZE TABLE notices COMPUTE STATISTICS;
```

### Monitor query performance
```sql
-- Check execution plan for active notices query
EXPLAIN PLAN FOR
SELECT * FROM vw_active_notices;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
```

## 🐛 Troubleshooting

### Common Issues

**Issue:** "Sequence does not exist"
**Solution:** Run schema.sql first to create sequences

**Issue:** "Table or view does not exist"
**Solution:** Ensure schema.sql completed without errors

**Issue:** "Integrity constraint violated"
**Solution:** Check foreign key references and ensure parent records exist

**Issue:** "ORA-01843: not a valid month"
**Solution:** Check date format in TO_TIMESTAMP functions

## 📞 Support

For issues or questions about the database schema:
1. Check this documentation
2. Review error messages in SQL output
3. Verify all prerequisite steps completed
4. Check Oracle documentation for version-specific features

## 📄 License

This database schema is part of the Digital Notice Board System educational project.

---

**Last Updated:** January 2026  
**Database Version:** 1.0  
**Oracle Version:** 11g or higher
