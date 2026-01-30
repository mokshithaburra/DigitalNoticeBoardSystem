-- ============================================================================
-- Digital Notice Board System - Sample Data
-- ============================================================================
-- Description: Sample/test data for development and testing
-- Database: Oracle SQL
-- Author: Digital Notice Board System Team
-- Created: January 2026
-- Note: Run this AFTER schema.sql
-- ============================================================================

-- Enable output
SET SERVEROUTPUT ON;

-- ============================================================================
-- INSERT ROLES
-- ============================================================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('Inserting roles...');
END;
/

INSERT INTO roles (role_id, role_name, role_description)
VALUES (role_seq.NEXTVAL, 'Admin', 'Administrator with full access to create, edit, and delete notices');

INSERT INTO roles (role_id, role_name, role_description)
VALUES (role_seq.NEXTVAL, 'Student', 'Student user with read-only access to view notices');

COMMIT;

-- ============================================================================
-- INSERT CATEGORIES
-- ============================================================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('Inserting categories...');
END;
/

INSERT INTO categories (category_id, category_name, category_description, display_color)
VALUES (category_seq.NEXTVAL, 'Exam', 'Examination-related announcements', '#DC2626');

INSERT INTO categories (category_id, category_name, category_description, display_color)
VALUES (category_seq.NEXTVAL, 'Event', 'College events and activities', '#7C3AED');

INSERT INTO categories (category_id, category_name, category_description, display_color)
VALUES (category_seq.NEXTVAL, 'Emergency', 'Urgent notifications', '#EF4444');

INSERT INTO categories (category_id, category_name, category_description, display_color)
VALUES (category_seq.NEXTVAL, 'General', 'General announcements', '#6B7280');

INSERT INTO categories (category_id, category_name, category_description, display_color)
VALUES (category_seq.NEXTVAL, 'Academic', 'Academic-related information', '#2563EB');

INSERT INTO categories (category_id, category_name, category_description, display_color)
VALUES (category_seq.NEXTVAL, 'Placement', 'Placement and career-related notices', '#059669');

COMMIT;

-- ============================================================================
-- INSERT USERS
-- ============================================================================

-- ⚠️ WARNING: SHA-256 hashing is used here FOR TESTING/DEVELOPMENT ONLY
-- ⚠️ In production, use proper password hashing algorithms:
--    - bcrypt (recommended)
--    - scrypt
--    - Argon2
-- SHA-256 is NOT secure for passwords (too fast, no built-in salt)
-- These test passwords must be replaced before any production use!

BEGIN
    DBMS_OUTPUT.PUT_LINE('Inserting users...');
END;
/

-- Admin users (password: admin123 - FOR TESTING ONLY, NEVER USE IN PRODUCTION)
INSERT INTO users (user_id, username, password_hash, full_name, email, role_id, is_active)
VALUES (
    user_seq.NEXTVAL, 
    'admin', 
    '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', -- SHA-256 of 'admin123' - TESTING ONLY
    'System Administrator',
    'admin@noticeboard.edu',
    (SELECT role_id FROM roles WHERE role_name = 'Admin'),
    1
);

INSERT INTO users (user_id, username, password_hash, full_name, email, role_id, is_active)
VALUES (
    user_seq.NEXTVAL,
    'john.admin',
    '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', -- SHA-256 of 'admin123' - TESTING ONLY
    'John Smith',
    'john.smith@noticeboard.edu',
    (SELECT role_id FROM roles WHERE role_name = 'Admin'),
    1
);

-- Student users (password: student123 - FOR TESTING ONLY, NEVER USE IN PRODUCTION)
INSERT INTO users (user_id, username, password_hash, full_name, email, role_id, is_active)
VALUES (
    user_seq.NEXTVAL,
    'student',
    '1c142b2d01aa34e9a36bde480645a57fd69e14155dacfab5a3f9257b77fdc8d8', -- SHA-256 of 'student123' - TESTING ONLY
    'Test Student',
    'student@noticeboard.edu',
    (SELECT role_id FROM roles WHERE role_name = 'Student'),
    1
);

INSERT INTO users (user_id, username, password_hash, full_name, email, role_id, is_active)
VALUES (
    user_seq.NEXTVAL,
    'alice.jones',
    '1c142b2d01aa34e9a36bde480645a57fd69e14155dacfab5a3f9257b77fdc8d8', -- SHA-256 of 'student123' - TESTING ONLY
    'Alice Jones',
    'alice.jones@student.edu',
    (SELECT role_id FROM roles WHERE role_name = 'Student'),
    1
);

INSERT INTO users (user_id, username, password_hash, full_name, email, role_id, is_active)
VALUES (
    user_seq.NEXTVAL,
    'bob.williams',
    '1c142b2d01aa34e9a36bde480645a57fd69e14155dacfab5a3f9257b77fdc8d8', -- SHA-256 of 'student123' - TESTING ONLY
    'Bob Williams',
    'bob.williams@student.edu',
    (SELECT role_id FROM roles WHERE role_name = 'Student'),
    1
);

COMMIT;

-- ============================================================================
-- INSERT SAMPLE NOTICES
-- ============================================================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('Inserting sample notices...');
END;
/

-- Notice 1: Mid-Term Examination Schedule (Exam, High Priority)
INSERT INTO notices (
    notice_id, title, description, category_id, priority, 
    created_by, expires_at, status
)
VALUES (
    notice_seq.NEXTVAL,
    'Mid-Term Examination Schedule',
    'Mid-term exams will be conducted from Feb 1-10, 2026. All students are requested to check the detailed timetable on the notice board. Admit cards will be issued from Jan 28, 2026.',
    (SELECT category_id FROM categories WHERE category_name = 'Exam'),
    'High',
    (SELECT user_id FROM users WHERE username = 'admin'),
    TO_TIMESTAMP('2026-02-10 23:59:59', 'YYYY-MM-DD HH24:MI:SS'),
    'Active'
);

-- Notice 2: Emergency Fire Drill (Emergency, High Priority)
INSERT INTO notices (
    notice_id, title, description, category_id, priority,
    created_by, expires_at, status
)
VALUES (
    notice_seq.NEXTVAL,
    'Emergency: Fire Drill Tomorrow',
    'Mandatory fire drill scheduled for Jan 24, 2026 at 11:00 AM. All students must evacuate buildings and gather at the designated assembly points. This is a mandatory safety exercise.',
    (SELECT category_id FROM categories WHERE category_name = 'Emergency'),
    'High',
    (SELECT user_id FROM users WHERE username = 'admin'),
    TO_TIMESTAMP('2026-01-24 23:59:59', 'YYYY-MM-DD HH24:MI:SS'),
    'Active'
);

-- Notice 3: Annual Tech Fest 2026 (Event, Medium Priority)
INSERT INTO notices (
    notice_id, title, description, category_id, priority,
    created_by, expires_at, status
)
VALUES (
    notice_seq.NEXTVAL,
    'Annual Tech Fest 2026',
    'Registration is now open for the annual tech fest. Submit your project entries, coding competition registrations, and hackathon team details by Jan 31, 2026. Visit the student activities office for more information.',
    (SELECT category_id FROM categories WHERE category_name = 'Event'),
    'Medium',
    (SELECT user_id FROM users WHERE username = 'john.admin'),
    TO_TIMESTAMP('2026-01-31 23:59:59', 'YYYY-MM-DD HH24:MI:SS'),
    'Active'
);

-- Notice 4: New Course Registration Open (Academic, Medium Priority)
INSERT INTO notices (
    notice_id, title, description, category_id, priority,
    created_by, expires_at, status
)
VALUES (
    notice_seq.NEXTVAL,
    'New Course Registration Open',
    'Registration for elective courses for the next semester is now open. Students can register through the online portal from Jan 25 to Jan 30, 2026. Contact your academic advisor for guidance.',
    (SELECT category_id FROM categories WHERE category_name = 'Academic'),
    'Medium',
    (SELECT user_id FROM users WHERE username = 'admin'),
    TO_TIMESTAMP('2026-01-30 23:59:59', 'YYYY-MM-DD HH24:MI:SS'),
    'Active'
);

-- Notice 5: Campus Maintenance Notice (General, Low Priority)
INSERT INTO notices (
    notice_id, title, description, category_id, priority,
    created_by, expires_at, status
)
VALUES (
    notice_seq.NEXTVAL,
    'Campus Maintenance Notice',
    'WiFi services will be temporarily unavailable on Jan 25, 2026 from 2:00 PM to 4:00 PM due to scheduled maintenance. We apologize for any inconvenience caused.',
    (SELECT category_id FROM categories WHERE category_name = 'General'),
    'Low',
    (SELECT user_id FROM users WHERE username = 'admin'),
    TO_TIMESTAMP('2026-01-25 23:59:59', 'YYYY-MM-DD HH24:MI:SS'),
    'Active'
);

-- Notice 6: Resume Writing Workshop (Placement, Low Priority)
INSERT INTO notices (
    notice_id, title, description, category_id, priority,
    created_by, expires_at, status
)
VALUES (
    notice_seq.NEXTVAL,
    'Resume Writing Workshop',
    'Join our resume writing and interview preparation workshop on Jan 28, 2026 at 3:00 PM in the placement cell. Industry experts will guide you on creating impactful resumes.',
    (SELECT category_id FROM categories WHERE category_name = 'Placement'),
    'Low',
    (SELECT user_id FROM users WHERE username = 'john.admin'),
    TO_TIMESTAMP('2026-01-28 23:59:59', 'YYYY-MM-DD HH24:MI:SS'),
    'Active'
);

-- Notice 7: Library Hours Extended (Academic, Low Priority)
INSERT INTO notices (
    notice_id, title, description, category_id, priority,
    created_by, expires_at, status
)
VALUES (
    notice_seq.NEXTVAL,
    'Library Hours Extended During Exam Week',
    'The central library will be open 24/7 during the exam week (Feb 1-7, 2026). Students can access study rooms and resources at any time. Please carry your student ID card.',
    (SELECT category_id FROM categories WHERE category_name = 'Academic'),
    'Medium',
    (SELECT user_id FROM users WHERE username = 'admin'),
    TO_TIMESTAMP('2026-02-07 23:59:59', 'YYYY-MM-DD HH24:MI:SS'),
    'Active'
);

-- Notice 8: Sports Day Registration (Event, Low Priority)
INSERT INTO notices (
    notice_id, title, description, category_id, priority,
    created_by, expires_at, status
)
VALUES (
    notice_seq.NEXTVAL,
    'Annual Sports Day - Registration Open',
    'Registration for Annual Sports Day 2026 is now open. Register for individual and team events by Feb 15, 2026. Contact the sports coordinator for more details.',
    (SELECT category_id FROM categories WHERE category_name = 'Event'),
    'Low',
    (SELECT user_id FROM users WHERE username = 'john.admin'),
    TO_TIMESTAMP('2026-02-15 23:59:59', 'YYYY-MM-DD HH24:MI:SS'),
    'Active'
);

-- Notice 9: Scholarship Application Deadline (General, Medium Priority)
INSERT INTO notices (
    notice_id, title, description, category_id, priority,
    created_by, expires_at, status
)
VALUES (
    notice_seq.NEXTVAL,
    'Merit Scholarship Application Deadline',
    'The deadline for merit-based scholarship applications for the academic year 2026-27 is Feb 20, 2026. Eligible students must submit their applications along with required documents to the accounts office.',
    (SELECT category_id FROM categories WHERE category_name = 'General'),
    'Medium',
    (SELECT user_id FROM users WHERE username = 'admin'),
    TO_TIMESTAMP('2026-02-20 23:59:59', 'YYYY-MM-DD HH24:MI:SS'),
    'Active'
);

-- Notice 10: Expired notice example
INSERT INTO notices (
    notice_id, title, description, category_id, priority,
    created_by, expires_at, status
)
VALUES (
    notice_seq.NEXTVAL,
    'Holiday Notice - Christmas Break',
    'College will remain closed from Dec 24, 2025 to Jan 1, 2026 for Christmas and New Year celebrations. Regular classes will resume on Jan 2, 2026.',
    (SELECT category_id FROM categories WHERE category_name = 'General'),
    'Low',
    (SELECT user_id FROM users WHERE username = 'admin'),
    TO_TIMESTAMP('2026-01-01 23:59:59', 'YYYY-MM-DD HH24:MI:SS'),
    'Expired'
);

COMMIT;

-- Update view counts for some notices (simulating user activity)
UPDATE notices SET view_count = 150 WHERE title = 'Mid-Term Examination Schedule';
UPDATE notices SET view_count = 89 WHERE title = 'Emergency: Fire Drill Tomorrow';
UPDATE notices SET view_count = 67 WHERE title = 'Annual Tech Fest 2026';
UPDATE notices SET view_count = 45 WHERE title = 'New Course Registration Open';
UPDATE notices SET view_count = 23 WHERE title = 'Campus Maintenance Notice';
UPDATE notices SET view_count = 34 WHERE title = 'Resume Writing Workshop';

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================');
    DBMS_OUTPUT.PUT_LINE('Sample data inserted successfully!');
    DBMS_OUTPUT.PUT_LINE('============================================');
END;
/

-- Display summary
SELECT 'Roles' AS table_name, COUNT(*) AS record_count FROM roles
UNION ALL
SELECT 'Categories', COUNT(*) FROM categories
UNION ALL
SELECT 'Users', COUNT(*) FROM users
UNION ALL
SELECT 'Notices', COUNT(*) FROM notices;

-- Display active notices count by category
BEGIN
    DBMS_OUTPUT.PUT_LINE(' ');
    DBMS_OUTPUT.PUT_LINE('Active Notices by Category:');
    DBMS_OUTPUT.PUT_LINE('----------------------------');
END;
/

SELECT 
    c.category_name,
    COUNT(n.notice_id) AS active_count
FROM categories c
LEFT JOIN notices n ON c.category_id = n.category_id 
    AND n.status = 'Active' 
    AND n.is_deleted = 0
GROUP BY c.category_name
ORDER BY c.category_name;

-- Display users by role
BEGIN
    DBMS_OUTPUT.PUT_LINE(' ');
    DBMS_OUTPUT.PUT_LINE('Users by Role:');
    DBMS_OUTPUT.PUT_LINE('----------------------------');
END;
/

SELECT 
    r.role_name,
    COUNT(u.user_id) AS user_count
FROM roles r
LEFT JOIN users u ON r.role_id = u.role_id
GROUP BY r.role_name
ORDER BY r.role_name;

BEGIN
    DBMS_OUTPUT.PUT_LINE(' ');
    DBMS_OUTPUT.PUT_LINE('============================================');
    DBMS_OUTPUT.PUT_LINE('Sample Credentials for Testing:');
    DBMS_OUTPUT.PUT_LINE('============================================');
    DBMS_OUTPUT.PUT_LINE('Admin Login:');
    DBMS_OUTPUT.PUT_LINE('  Username: admin');
    DBMS_OUTPUT.PUT_LINE('  Password: admin123');
    DBMS_OUTPUT.PUT_LINE(' ');
    DBMS_OUTPUT.PUT_LINE('Student Login:');
    DBMS_OUTPUT.PUT_LINE('  Username: student');
    DBMS_OUTPUT.PUT_LINE('  Password: student123');
    DBMS_OUTPUT.PUT_LINE('============================================');
    DBMS_OUTPUT.PUT_LINE('Database is ready for use!');
    DBMS_OUTPUT.PUT_LINE('============================================');
END;
/
