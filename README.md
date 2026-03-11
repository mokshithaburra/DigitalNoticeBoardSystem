# Digital Notice Board System

Java web application (Servlet + JSP + HTML/CSS/JS) for admin/student notice management.

## Tech Stack

### Backend
| Technology | Version | Purpose |
|---|---|---|
| Java | 21 (LTS) | Core programming language |
| Java Servlets | 4.0.1 (`javax.servlet-api`) | HTTP request handling and routing |
| JSP (JavaServer Pages) | — | Server-side HTML templating |
| Apache Tomcat | 9.0+ | Servlet container / application server |
| Apache Maven | 3.9+ | Build automation and dependency management |
| Oracle Database | 21c XE / 23ai Free | Relational database for persistence |
| Oracle JDBC Thin Driver | 23.4.0.24.05 (`ojdbc11`) | Database connectivity |
| jBCrypt | 0.4 | Password hashing (bcrypt) |

### Frontend
| Technology | Purpose |
|---|---|
| HTML5 | Page structure and semantic markup |
| CSS3 | Custom styling (1050+ lines), responsive design, CSS variables |
| Vanilla JavaScript (ES6+) | Client-side interactivity, Fetch API, DOM manipulation |
| Google Fonts (Poppins) | Typography |

### Architecture & Patterns
| Pattern | Details |
|---|---|
| MVC (Model-View-Controller) | Models → Java POJOs, Views → JSP/HTML, Controllers → Servlets |
| DAO (Data Access Object) | `UserDAO`, `NoticeDAO` — abstracts all database operations |
| REST-style JSON APIs | `/api/notices`, `/api/admin/notices` — JSON over HTTP |
| Session-based Authentication | `HttpSession` with role-based access control (admin / student) |
| WAR Packaging | Deployed as `digital-notice-board.war` on Tomcat |

### Project Statistics
| Metric | Value |
|---|---|
| Java source files | 13 (8 servlets, 2 DAOs, 2 models, 1 config) |
| Frontend files | 9 (4 HTML, 4 JS, 1 CSS) |
| JSP templates | 4 |
| Total lines of code | ~3450 (Java 1240 · CSS 1058 · JS 523 · JSP 335 · HTML 289) |
| REST API endpoints | 8+ (CRUD for notices, auth, role-based feeds) |
| Database tables | 2 (`users`, `notices`) |
| Notice categories | 6 (Exam, Event, Emergency, General, Academic, Placement) |
| Priority levels | 3 (High, Medium, Low) |

## Resume-Ready Project Description

> **Digital Notice Board System** — Full-stack Java web application built with **Java 21, Servlets 4.0, JSP, Oracle Database, and a vanilla JavaScript frontend** that digitizes institutional notice management for administrators and students.
>
> - Engineered an **MVC-architecture** web app (~3450 LOC across 26 source files) using **Java Servlets, JSP, HTML5/CSS3/JavaScript**, and **Oracle Database**, deployed as a WAR on **Apache Tomcat 9**.
> - Designed and implemented **8+ RESTful API endpoints** with **JSON serialization** for real-time CRUD operations on notices, supporting **6 categories** and **3 priority levels** with automatic expiry tracking.
> - Built a **role-based access control** system with **session-based authentication** and **BCrypt password hashing** (with automatic plaintext-to-hash migration on login), securing admin and student workflows.
> - Developed a **responsive, mobile-first frontend** (1050+ lines of CSS) featuring real-time search, category filtering, and **auto-refreshing notice feeds** (10-second polling) for the student dashboard.
> - Implemented the **DAO pattern** with **Oracle JDBC Thin Driver** for all database operations across 2 normalized tables (`users`, `notices`), with schema-qualified queries and environment-variable-driven configuration.
> - Delivered **dual admin/student dashboards**: admin dashboard supports full notice lifecycle management (create, edit, delete, view active/expired); student dashboard provides a filterable, searchable, priority-sorted notice feed.

## 0) Canonical Project Structure (Use This Only)

```text
.
├─ pom.xml
├─ src/
│  └─ main/
│     ├─ java/com/digitalnoticeboard/
│     │  ├─ config/
│     │  ├─ dao/
│     │  ├─ model/
│     │  └─ servlet/
│     └─ webapp/
│        ├─ index.html
│        ├─ admin/
│        ├─ auth/
│        ├─ student/
│        ├─ css/
│        ├─ js/
│        └─ WEB-INF/web.xml
└─ target/   (generated, ignored in git)
```

Placement rules:

- Put all Java source only in `src/main/java`.
- Put all frontend HTML/CSS/JS only in `src/main/webapp`.
- Do not create duplicate frontend folders at repository root.
- Do not edit or commit anything in `target/`.

## 1) Required Software (Final List)

Install these first:

1. **JDK 21** (LTS)  
	- Required by `pom.xml` compiler settings.
2. **Apache Maven 3.9+**  
	- For dependency resolution, build, and packaging.
3. **Apache Tomcat 9.0+**  
	- Servlet 4.0 runtime (`javax.servlet-api:4.0.1`).
4. **Oracle Database (recommended: Oracle Database 23ai Free or 21c XE)**  
  - Backend persistence for users and notices.
5. **Git** (optional but recommended)
	- Version control and reproducible setup.
6. **VS Code** (optional but recommended)
	- Development/editor workflow.

## 2) Java/Maven Dependencies

Defined in `pom.xml`:

- `javax.servlet:javax.servlet-api:4.0.1` (scope `provided`)
- `com.oracle.database.jdbc:ojdbc11:23.4.0.24.05`

## 3) Runtime Requirements

### Environment variables (recommended)

Set these for database connectivity:

- `DB_URL` (example: `jdbc:oracle:thin:@localhost:1521:XE`)
- `DB_USER` (example: `DNB_APP` or `SYSTEM`)
- `DB_PASSWORD` (example: your Oracle password)

If not provided, app falls back to:

- URL: `jdbc:oracle:thin:@localhost:1521:XE`
- User: `system`
- Password: empty string

## 4) Database Setup

Create schema/tables (Oracle):

```sql
-- Run as SYSTEM (or another privileged account)
CREATE USER DNB_APP IDENTIFIED BY dnb_app_password;
GRANT CONNECT, RESOURCE TO DNB_APP;

-- Then connect as DNB_APP and run:

CREATE TABLE users (
  user_id NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
  username VARCHAR2(100) NOT NULL UNIQUE,
  password VARCHAR2(255) NOT NULL,
  role VARCHAR2(20) NOT NULL,
  email VARCHAR2(255)
);

CREATE TABLE notices (
  notice_id NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
  title VARCHAR2(255) NOT NULL,
  description CLOB NOT NULL,
  category VARCHAR2(100) NOT NULL,
  priority NUMBER(1) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT SYSTIMESTAMP,
  expiry_date DATE NULL,
  created_by NUMBER NOT NULL,
  CONSTRAINT fk_notices_user
	 FOREIGN KEY (created_by) REFERENCES users(user_id)
);
```

Note: Oracle does not use MySQL-style `AUTO_INCREMENT`, `CREATE DATABASE`, or `USE` statements.

Seed example users:

```sql
INSERT INTO users (username, password, role, email)
VALUES
('admin1', 'admin123', 'admin', 'admin1@example.com'),
('student1', 'student123', 'student', 'student1@example.com');
```

## 5) Build and Run

From project root:

```bash
mvn clean package
```

Deploy generated WAR:

- `target/digital-notice-board.war` -> Tomcat `webapps/`

Open in browser:

- `http://localhost:8080/digital-notice-board/`

## 6) Frontend-Backend Integration Status

Current integration points:

- Login form posts to `/login` and redirects by role.
- Admin dashboard (`/admin/admin-dashboard.html`) uses `/api/admin/notices` for create/update/delete/list.
- Student dashboard (`/student/student-dashboard.html`) uses `/api/notices` for notice feed.
- Both dashboards now render **only backend data** (no static placeholder cards/rows).

## 7) Known Security Improvements to Consider Next

The app works end-to-end, but these are recommended for production:

- Store hashed passwords instead of plaintext.
- Move DB secrets to a secrets manager or container/runtime config.
- Add CSRF protection for state-changing endpoints.

## 8) Oracle Notices (Important)

- Oracle JDBC Thin driver (`ojdbc11`) does **not** require Oracle Instant Client.
- Ensure listener/SID is reachable (default example: port `1521`, SID `XE`).
- If your Oracle setup uses a different service name, update `DB_URL` accordingly.

## 9) Login Troubleshooting (Oracle + Tomcat)

If login always shows `Invalid credentials`, check these in order:

1. **Tomcat process env vars**
  - Setting `$env:DB_*` in one PowerShell does not always reach an already running Tomcat process.
  - On Windows, create `TOMCAT_HOME/bin/setenv.bat` with:

```bat
set DB_URL=jdbc:oracle:thin:@localhost:1521:XE
set DB_USER=SYSTEM
set DB_PASSWORD=your_password
set DB_SCHEMA=SYSTEM
```

  - Restart Tomcat after adding/updating `setenv.bat`.

2. **Schema mismatch**
  - If tables are in `DNB_APP` but app connects as `SYSTEM`, set:
  - `DB_SCHEMA=DNB_APP`

3. **SID mismatch**
  - Ensure SID is exactly `XE`.

4. **Verify users data exists**

```sql
SELECT username, role FROM users;
```

  - Expected roles: `admin` and `student`.