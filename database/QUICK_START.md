# Quick Start Guide - Database Setup

## Prerequisites
- Oracle Database 11g or higher installed
- SQL*Plus or Oracle SQL Developer
- Database user with CREATE privileges

## 5-Minute Setup

### Step 1: Connect to Database
```bash
sqlplus username/password@database
```

### Step 2: Create Schema
```sql
@database/schema.sql
```
**Expected Output:** "Database schema created successfully!"

### Step 3: Load Sample Data
```sql
@database/sample_data.sql
```
**Expected Output:** Summary of inserted records

### Step 4: Verify
```sql
SELECT COUNT(*) FROM notices WHERE status = 'Active';
```
**Expected:** 9 active notices

## Test the Database

### Login as Admin
```sql
SELECT u.user_id, u.username, r.role_name
FROM users u
JOIN roles r ON u.role_id = r.role_id
WHERE u.username = 'admin'
  AND u.password_hash = '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9'
  AND u.is_active = 1;
```

### Get Active Notices
```sql
SELECT * FROM vw_active_notices;
```

### Get Notice Statistics
```sql
SELECT * FROM vw_notice_stats_by_category;
```

## Common Commands

### View All Tables
```sql
SELECT table_name FROM user_tables 
WHERE table_name IN ('ROLES', 'CATEGORIES', 'USERS', 'NOTICES');
```

### View All Sequences
```sql
SELECT sequence_name FROM user_sequences;
```

### View All Views
```sql
SELECT view_name FROM user_views WHERE view_name LIKE 'VW_%';
```

### View All Procedures
```sql
SELECT object_name, object_type 
FROM user_procedures 
WHERE object_type IN ('PROCEDURE', 'FUNCTION');
```

## Troubleshooting

### Error: "sequence does not exist"
**Solution:** Run schema.sql first

### Error: "table or view does not exist"
**Solution:** Check that schema.sql completed without errors

### Error: "insufficient privileges"
**Solution:** Ensure user has CREATE TABLE, CREATE SEQUENCE, CREATE TRIGGER privileges

## Sample Credentials

| Role | Username | Password |
|------|----------|----------|
| Admin | admin | admin123 |
| Student | student | student123 |

**Note:** Passwords shown here are for testing. In production, use secure passwords.

## Next Steps

1. ✅ Database setup complete
2. 📖 Read [README.md](README.md) for detailed documentation
3. 📊 Check [ER_DIAGRAM.md](ER_DIAGRAM.md) for schema structure
4. 🔧 Start building the Flask backend to connect to this database

## Support

For issues:
1. Check [README.md](README.md) troubleshooting section
2. Verify Oracle version compatibility
3. Review error messages in SQL output
4. Ensure all prerequisite steps completed

---

**Estimated Setup Time:** 5 minutes  
**Difficulty Level:** Beginner-friendly  
**Status:** Production-ready
