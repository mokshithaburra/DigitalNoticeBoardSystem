# Entity-Relationship Diagram

## Digital Notice Board System - Database ER Diagram

### Tables and Relationships

```
┌─────────────────────┐
│       ROLES         │
├─────────────────────┤
│ PK role_id          │
│    role_name        │
│    role_description │
│    created_at       │
└──────────┬──────────┘
           │
           │ 1
           │
           │
           │ M
    ┌──────┴───────────────┐
    │       USERS          │
    ├──────────────────────┤
    │ PK user_id           │
    │    username          │
    │    password_hash     │
    │    full_name         │
    │    email             │
    │ FK role_id           │
    │    is_active         │
    │    last_login        │
    │    created_at        │
    │    updated_at        │
    └──────────┬───────────┘
               │
               │ 1
               │
               │
               │ M (created_by)
        ┌──────┴──────────────────┐
        │       NOTICES           │
        ├─────────────────────────┤
        │ PK notice_id            │
        │    title                │
        │    description          │
        │ FK category_id          │
        │    priority             │
        │ FK created_by           │
        │    created_at           │
        │    updated_at           │
        │    expires_at           │
        │    status               │
        │    view_count           │
        │    is_deleted           │
        └──────────┬──────────────┘
                   │
                   │ M
                   │
                   │
                   │ 1
        ┌──────────┴──────────────┐
        │      CATEGORIES         │
        ├─────────────────────────┤
        │ PK category_id          │
        │    category_name        │
        │    category_description │
        │    display_color        │
        │    created_at           │
        └─────────────────────────┘
```

## Relationship Details

### ROLES → USERS (One-to-Many)
- One role can be assigned to many users
- Each user must have exactly one role
- Foreign Key: users.role_id → roles.role_id
- Cascade: ON DELETE CASCADE

### USERS → NOTICES (One-to-Many)
- One user (admin) can create many notices
- Each notice must be created by one user
- Foreign Key: notices.created_by → users.user_id
- Cascade: ON DELETE CASCADE

### CATEGORIES → NOTICES (One-to-Many)
- One category can contain many notices
- Each notice must belong to one category
- Foreign Key: notices.category_id → categories.category_id
- Cascade: ON DELETE CASCADE

## Cardinality Summary

| Relationship | Type | Description |
|-------------|------|-------------|
| ROLES → USERS | 1:M | One role, many users |
| USERS → NOTICES | 1:M | One user creates many notices |
| CATEGORIES → NOTICES | 1:M | One category, many notices |

## Constraints

### Primary Keys
- roles.role_id
- categories.category_id
- users.user_id
- notices.notice_id

### Foreign Keys
- users.role_id → roles.role_id
- notices.category_id → categories.category_id
- notices.created_by → users.user_id

### Unique Constraints
- roles.role_name
- categories.category_name
- users.username
- users.email

### Check Constraints
- roles.role_name IN ('Admin', 'Student')
- categories.category_name IN ('Exam', 'Event', 'Emergency', 'General', 'Academic', 'Placement')
- users.is_active IN (0, 1)
- users.email matches email format pattern
- notices.priority IN ('High', 'Medium', 'Low')
- notices.status IN ('Active', 'Expired', 'Draft')
- notices.is_deleted IN (0, 1)
- notices.expires_at > notices.created_at

## Data Types

### ROLES
- role_id: NUMBER (Sequence-generated)
- role_name: VARCHAR2(50)
- role_description: VARCHAR2(200)
- created_at: TIMESTAMP

### CATEGORIES
- category_id: NUMBER (Sequence-generated)
- category_name: VARCHAR2(50)
- category_description: VARCHAR2(200)
- display_color: VARCHAR2(7) (Hex color code)
- created_at: TIMESTAMP

### USERS
- user_id: NUMBER (Sequence-generated)
- username: VARCHAR2(50)
- password_hash: VARCHAR2(255) (SHA-256 or stronger)
- full_name: VARCHAR2(100)
- email: VARCHAR2(100)
- role_id: NUMBER (FK)
- is_active: NUMBER(1) (Boolean: 0 or 1)
- last_login: TIMESTAMP
- created_at: TIMESTAMP
- updated_at: TIMESTAMP

### NOTICES
- notice_id: NUMBER (Sequence-generated)
- title: VARCHAR2(200)
- description: CLOB (Large text)
- category_id: NUMBER (FK)
- priority: VARCHAR2(20)
- created_by: NUMBER (FK)
- created_at: TIMESTAMP
- updated_at: TIMESTAMP
- expires_at: TIMESTAMP
- status: VARCHAR2(20)
- view_count: NUMBER (Default: 0)
- is_deleted: NUMBER(1) (Boolean: 0 or 1)

## Indexes

### Performance Indexes

**USERS Table:**
- idx_users_username ON username
- idx_users_email ON email
- idx_users_role ON role_id

**NOTICES Table:**
- idx_notices_category ON category_id
- idx_notices_priority ON priority
- idx_notices_status ON status
- idx_notices_created_by ON created_by
- idx_notices_created_at ON created_at DESC
- idx_notices_expires_at ON expires_at
- idx_notices_active_priority ON (status, priority, created_at DESC)
- idx_notices_is_deleted ON is_deleted

## Business Rules

1. **User Authentication**
   - Users must have unique usernames and emails
   - Passwords must be hashed before storage
   - Only active users can log in

2. **Role-Based Access**
   - Admin users can create, edit, and delete notices
   - Student users can only view active notices
   - Role assignment is mandatory

3. **Notice Management**
   - Notices must have a future expiry date
   - Priority levels determine display order
   - Expired notices are hidden from students
   - Soft delete preserves data integrity

4. **Category System**
   - Fixed set of 6 categories
   - Each notice belongs to exactly one category
   - Categories help with filtering and organization

5. **Data Integrity**
   - Foreign key constraints ensure referential integrity
   - Triggers maintain timestamp consistency
   - Check constraints enforce valid values
   - Sequences ensure unique IDs

## Sample Queries

### Get Active Notices for Student Dashboard
```sql
SELECT 
    n.notice_id,
    n.title,
    n.description,
    c.category_name,
    c.display_color,
    n.priority,
    n.created_at,
    n.expires_at
FROM notices n
JOIN categories c ON n.category_id = c.category_id
WHERE n.status = 'Active'
  AND n.is_deleted = 0
  AND n.expires_at > CURRENT_TIMESTAMP
ORDER BY 
    CASE n.priority
        WHEN 'High' THEN 1
        WHEN 'Medium' THEN 2
        WHEN 'Low' THEN 3
    END,
    n.created_at DESC;
```

### Get Notice Count by Category for Admin
```sql
SELECT 
    c.category_name,
    COUNT(n.notice_id) AS total_notices,
    SUM(CASE WHEN n.status = 'Active' THEN 1 ELSE 0 END) AS active_count,
    SUM(CASE WHEN n.priority = 'High' THEN 1 ELSE 0 END) AS high_priority_count
FROM categories c
LEFT JOIN notices n ON c.category_id = n.category_id AND n.is_deleted = 0
GROUP BY c.category_name
ORDER BY c.category_name;
```

### User Authentication Query
```sql
SELECT 
    u.user_id,
    u.username,
    u.full_name,
    u.email,
    r.role_name
FROM users u
JOIN roles r ON u.role_id = r.role_id
WHERE u.username = :username
  AND u.password_hash = :password_hash
  AND u.is_active = 1;
```

---

**Note:** This ER diagram represents the logical structure of the database. Physical implementation includes additional objects like sequences, triggers, views, and stored procedures not shown here.
